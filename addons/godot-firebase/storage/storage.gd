@tool
## @meta-authors SIsilicon
## @meta-version 2.2
## The Storage API for Firebase.
## This object handles all firebase storage tasks, variables and references. To use this API, you must first create a [StorageReference] with [method ref]. With the reference, you can then query and manipulate the file or folder in the cloud storage.
## 
## [i]Note: In HTML builds, you must configure [url=https://firebase.google.com/docs/storage/web/download-files#cors_configuration]CORS[/url] in your storage bucket.[i] 
class_name FirebaseStorage
extends Node

## @arg-types int, int, PoolStringArray
## @arg-enums HTTPRequest.Result, HTTPClient.ResponseCode
## Emitted when a [StorageTask] has finished successful.
signal task_successful(result, response_code, data)

## @arg-types int, int, PoolStringArray
## @arg-enums HTTPRequest.Result, HTTPClient.ResponseCode
## Emitted when a [StorageTask] has finished with an error.
signal task_failed(result, response_code, data)

## The current storage bucket the Storage API is referencing.
var bucket : String

## @default false
## Whether a task is currently being processed.
var requesting : bool = false

var _auth : Dictionary
var _config : Dictionary

var _references : Dictionary = {}

var _base_url : String = "https://firebasestorage.googleapis.com"
var _extended_url : String = "/v0/b/[APP_ID]/o/[FILE_PATH]"
var _root_ref : StorageReference

var _http_client : HTTPClient = HTTPClient.new()
var _pending_tasks : Array = []

var _current_task : StorageTask
var _response_code : int
var _response_headers : PackedStringArray
var _response_data : PackedByteArray
var _content_length : int
var _reading_body : bool

func _notification(what : int) -> void:
	if what == NOTIFICATION_INTERNAL_PROCESS:
		_internal_process(get_process_delta_time())

func _internal_process(_delta : float) -> void:
	if not requesting:
		set_process_internal(false)
		return
	
	var task = _current_task
	
	match _http_client.get_status():
		HTTPClient.STATUS_DISCONNECTED:
			var tls := TLSOptions.client()
			_http_client.connect_to_host(_base_url, 443, tls)
		
		HTTPClient.STATUS_RESOLVING, \
		HTTPClient.STATUS_REQUESTING, \
		HTTPClient.STATUS_CONNECTING:
			_http_client.poll()
		
		HTTPClient.STATUS_CONNECTED:
			var err := _http_client.request_raw(task._method, task._url, task._headers, task.data)
			if err:
				_finish_request(HTTPRequest.RESULT_CONNECTION_ERROR)
		
		HTTPClient.STATUS_BODY:
			if _http_client.has_response() or _reading_body:
				_reading_body = true
				
				# If there is a response...
				if _response_headers.is_empty():
					_response_headers = _http_client.get_response_headers() # Get response headers.
					_response_code = _http_client.get_response_code()
					
					for header in _response_headers:
						if "Content-Length" in header:
							_content_length = header.trim_prefix("Content-Length: ").to_int()
				
				_http_client.poll()
				var chunk = _http_client.read_response_body_chunk() # Get a chunk.
				if chunk.size() == 0:
					# Got nothing, wait for buffers to fill a bit.
					pass
				else:
					_response_data += chunk # Append to read buffer.
					if _content_length != 0:
						task.progress = float(_response_data.size()) / _content_length
				
				if _http_client.get_status() != HTTPClient.STATUS_BODY:
					task.progress = 1.0
					_finish_request(HTTPRequest.RESULT_SUCCESS)
			else:
				task.progress = 1.0
				_finish_request(HTTPRequest.RESULT_SUCCESS)
		
		HTTPClient.STATUS_CANT_CONNECT:
			_finish_request(HTTPRequest.RESULT_CANT_CONNECT)
		HTTPClient.STATUS_CANT_RESOLVE:
			_finish_request(HTTPRequest.RESULT_CANT_RESOLVE)
		HTTPClient.STATUS_CONNECTION_ERROR:
			_finish_request(HTTPRequest.RESULT_CONNECTION_ERROR)

## @args path
## @arg-defaults ""
## @return StorageReference
## Returns a reference to a file or folder in the storage bucket. It's this reference that should be used to control the file/folder on the server end.
func ref(path := "") -> StorageReference:
	if not _config:
		return null
	
	# Create a root storage reference if there's none
	# and we're not making one.
	if path != "" and not _root_ref:
		_root_ref = ref()
	
	path = _simplify_path(path)
	if not _references.has(path):
		var ref := StorageReference.new()
		_references[path] = ref
		ref.valid = true
		ref.bucket = bucket
		ref.full_path = path
		ref.name = path.get_file()
		ref.parent = ref(path.path_join(".."))
		ref.root = _root_ref
		ref.storage = self
		return ref
	else:
		return _references[path]

func _set_config(config_json : Dictionary) -> void:
	_config = config_json
	if bucket != _config.storageBucket:
		bucket = _config.storageBucket
		_http_client.close()

func _upload(data : PackedByteArray, headers : PackedStringArray, ref : StorageReference, meta_only : bool) -> StorageTask:
	if not (_config and _auth):
		return null
	
	var task := StorageTask.new()
	task.ref = ref
	task._url = _get_file_url(ref)
	task.action = StorageTask.Task.TASK_UPLOAD_META if meta_only else StorageTask.Task.TASK_UPLOAD
	task._headers = headers
	task.data = data
	_process_request(task)
	return task

func _download(ref : StorageReference, meta_only : bool, url_only : bool) -> StorageTask:
	if not (_config and _auth):
		return null
	
	var info_task := StorageTask.new()
	info_task.ref = ref
	info_task._url = _get_file_url(ref)
	info_task.action = StorageTask.Task.TASK_DOWNLOAD_URL if url_only else StorageTask.Task.TASK_DOWNLOAD_META
	_process_request(info_task)
	
	if url_only or meta_only:
		return info_task
	
	var task := StorageTask.new()
	task.ref = ref
	task._url = _get_file_url(ref) + "?alt=media&token="
	task.action = StorageTask.Task.TASK_DOWNLOAD
	_pending_tasks.append(task)
	
	await info_task.task_finished
	if info_task.data is Dictionary and not info_task.data.has("error"):
		task._url += info_task.data.downloadTokens
	else:
		task.data = info_task.data
		task.response_headers = info_task.response_headers
		task.response_code = info_task.response_code
		task.result = info_task.result
		task.finished = true
		task.emit_signal("task_finished")
		emit_signal("task_failed", task.result, task.response_code, task.data)
		_pending_tasks.erase(task)
	
	if info_task.data and not info_task.data.has("error"):
		task._url += info_task.data.downloadTokens
	else:
		task.data = info_task.data
		task.response_headers = info_task.response_headers
		task.response_code = info_task.response_code
		task.result = info_task.result
		task.finished = true
		task.emit_signal("task_finished")
		emit_signal("task_failed", task.result, task.response_code, task.data)
		_pending_tasks.erase(task)
	
	return task

func _list(ref : StorageReference, list_all : bool) -> StorageTask:
	if not (_config and _auth):
		return null
	
	var task := StorageTask.new()
	task.ref = ref
	task._url = _get_file_url(_root_ref).trim_suffix("/")
	task.action = StorageTask.Task.TASK_LIST_ALL if list_all else StorageTask.Task.TASK_LIST
	_process_request(task)
	return task

func _delete(ref : StorageReference) -> StorageTask:
	if not (_config and _auth):
		return null
	
	var task := StorageTask.new()
	task.ref = ref
	task._url = _get_file_url(ref)
	task.action = StorageTask.Task.TASK_DELETE
	_process_request(task)
	return task

func _process_request(task : StorageTask) -> void:
	if requesting:
		_pending_tasks.append(task)
		return
	requesting = true
	
	var headers = Array(task._headers)
	headers.append("Authorization: Bearer " + _auth.idtoken)
	task._headers = PackedStringArray(headers)
	
	_current_task = task
	_response_code = 0
	_response_headers = PackedStringArray()
	_response_data = PackedByteArray()
	_content_length = 0
	_reading_body = false
	
	if not _http_client.get_status() in [HTTPClient.STATUS_CONNECTED, HTTPClient.STATUS_DISCONNECTED]:
		_http_client.close()
	set_process_internal(true)

func _finish_request(result : int) -> void:
	var task := _current_task
	requesting = false
	
	task.result = result
	task.response_code = _response_code
	task.response_headers = _response_headers
	
	match task.action:
		StorageTask.Task.TASK_DOWNLOAD:
			task.data = _response_data
		
		StorageTask.Task.TASK_DELETE:
			_references.erase(task.ref.full_path)
			task.ref.valid = false
			if typeof(task.data) == TYPE_PACKED_BYTE_ARRAY:
				task.data = null
		
		StorageTask.Task.TASK_DOWNLOAD_URL:
			var data = JSON.parse_string(_response_data.get_string_from_utf8())
			if data is Dictionary and data.has("downloadTokens"):
				task.data = _base_url + _get_file_url(task.ref) + "?alt=media&token=" + data["downloadTokens"]
			else:
				task.data = ""
		
			if task.action == StorageTask.Task.TASK_LIST or task.action == StorageTask.Task.TASK_LIST_ALL:
				var json = JSON.new()
				var parse_error = json.parse(_response_data.get_string_from_utf8())
				if parse_error != OK:
					push_error("JSON Parse Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
					task.error = parse_error
					task.finished = true
					return
					
				var json_dict: Dictionary = json.data
				var items: Array = []
				if json_dict.has("items"):
					for item in json_dict["items"]:
						# Firebase returns item as Dictionary with "name", "bucket", etc.
						var item_name: String = item["name"]
						if item["bucket"] != bucket:
							continue
						if not item_name.begins_with(task.ref.full_path):
							continue
							
						if task.action == StorageTask.Task.TASK_LIST:
							# Only return direct children (one level deep) + add trailing slash for folders
							var parts: PackedStringArray = item_name.split("/")
							var slash_count: int = task.ref.full_path.count("/")
							var relative_name: String = ""
							
							 # Build the name of the direct child
							for i in range(slash_count + 1, parts.size()):
								relative_name += parts[i]
								if i < parts.size() - 1:
									relative_name += "/"
								break  # We only want the first level after the prefix
							
							 # If it's a "folder" (has more path segments), add trailing slash
							if parts.size() > slash_count + 1:
								if not relative_name.ends_with("/"):
									relative_name += "/"
							
							if relative_name.is_empty():
								continue
							if relative_name in items:
								continue
							items.append(relative_name)
						else:
							# TASK_LIST_ALL → return full relative path (no trimming)
							var relative_path: String = item_name.substr(task.ref.full_path.length())
							if relative_path.is_empty():
								continue
							items.append(relative_path)
				task.data = items
				task.finished = true
		
		_:
			var json = JSON.new()
			var parse_error = json.parse(_response_data.get_string_from_utf8())

			if parse_error != OK:
				push_error("JSON Parse Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
				# Handle error (e.g., task.error = parse_error; task.finished.emit())
				return  # Or continue as needed

			task.data = json.data
	
	var next_task : StorageTask
	if not _pending_tasks.is_empty():
		next_task = _pending_tasks.pop_front()
	
	task.finished = true
	task.emit_signal("task_finished")
	if typeof(task.data) == TYPE_DICTIONARY and task.data.has("error"):
		emit_signal("task_failed", task.result, task.response_code, task.data)
	else:
		emit_signal("task_successful", task.result, task.response_code, task.data)
	
	while true:
		if next_task and not next_task.finished:
			_process_request(next_task)
			break
		elif not _pending_tasks.is_empty():
			next_task = _pending_tasks.pop_front()
		else:
			break


func _get_file_url(ref : StorageReference) -> String:
	var url := _extended_url.replace("[APP_ID]", ref.bucket)
	return url.replace("[FILE_PATH]", ref.full_path.replace("/", "%2F"))

# Removes any "../" or "./" in the file path.
func _simplify_path(path : String) -> String:
	var dirs := path.split("/")
	var new_dirs := []
	for dir in dirs:
		if dir == "..":
			new_dirs.pop_back()
		elif dir == ".":
			pass
		else:
			new_dirs.push_back(dir)
	
	var new_path := "/".join(PackedStringArray(new_dirs))
	new_path = new_path.replace("//", "/")
	new_path = new_path.replace("\\", "/")
	return new_path

func _on_FirebaseAuth_login_succeeded(auth_token : Dictionary) -> void:
	_auth = auth_token

func _on_FirebaseAuth_token_refresh_succeeded(auth_result : Dictionary) -> void:
	_auth = auth_result

func _on_FirebaseAuth_logout() -> void:
	_auth = {}
