@tool
## @meta-authors Nicolò 'fenix' Santilio
## @meta-version 2.4
## Firestore module for Godot 4

class_name FirebaseFirestore
extends Node

signal listed_documents(documents)
signal result_query(result)
signal error(code, status, message)

enum Requests {
	NONE = -1,
	LIST,
	QUERY
}

const CACHE_SIZE_UNLIMITED = -1
const _CACHE_EXTENSION = ".fscache"
const _CACHE_RECORD_FILE = "RmlyZXN0b3JlIGNhY2hlLXJlY29yZHMu.fscache"
const _AUTHORIZATION_HEADER = "Authorization: Bearer "
const _MAX_POOLED_REQUEST_AGE = 30

var request = -1
var persistence_enabled = true
var networking: bool = true: set = set_networking
var collections = {}
var auth = {}
var _config = {}
var _cache_loc
var _encrypt_key = "5vg76n90345f7w390346" if OS.get_name() in ["HTML5", "UWP"] else OS.get_unique_id()
var _base_url = "https://firestore.googleapis.com/v1/"
var _extended_url = "projects/[PROJECT_ID]/databases/(default)/documents/"
var _query_suffix = ":runQuery"
var _request_list_node
var _requests_queue = []
var _current_query
var _http_request_pool = []
var _offline: bool = false: set = _set_offline

func _ready() -> void:
	_request_list_node = HTTPRequest.new()
	_request_list_node.connect("request_completed", Callable(self, "_on_request_completed"))
	_request_list_node.timeout = 5
	add_child(_request_list_node)

func _process(delta: float) -> void:
	for i in range(_http_request_pool.size() - 1, -1, -1):
		var request = _http_request_pool[i]
		if not request.get_meta("requesting"):
			var lifetime = request.get_meta("lifetime") + delta
			if lifetime > _MAX_POOLED_REQUEST_AGE:
				request.queue_free()
				_http_request_pool.remove_at(i)
			else:
				request.set_meta("lifetime", lifetime)

func collection(path):
	if not collections.has(path):
		var coll = FirestoreCollection.new()
		coll._extended_url = _extended_url
		coll._base_url = _base_url
		coll._config = _config
		coll.auth = auth
		coll.collection_name = path
		coll.firestore = self
		collections[path] = coll
		return coll
	else:
		return collections[path]

func query(query) -> FirestoreTask:
	if auth:
		var firestore_task = FirestoreTask.new()
		firestore_task.connect("result_query", Callable(self, "_on_result_query"))
		firestore_task.connect("error", Callable(self, "_on_error"))
		firestore_task.action = FirestoreTask.Task.TASK_QUERY
		var body = { structuredQuery = query.query }
		var url = _base_url + _extended_url + _query_suffix

		firestore_task.data = query
		firestore_task._fields = JSON.stringify(body)
		firestore_task._url = url
		firestore_task._headers = PackedStringArray([_AUTHORIZATION_HEADER + auth.idtoken])
		_pooled_request(firestore_task)
		return firestore_task
	else:
		printerr("Unauthorized")
		return null

func list(path: String, page_size: int = 0, page_token: String = "", order_by: String = "") -> FirestoreTask:
	if auth: 
		var firestore_task = FirestoreTask.new()
		firestore_task.connect("listed_documents", Callable(self, "_on_listed_documents"))
		firestore_task.connect("error", Callable(self, "_on_error"))
		firestore_task.action = FirestoreTask.Task.TASK_LIST
		var url
		if path.strip_edges() != "":
			url = _base_url + _extended_url + path + "/"
		else:
			url = _base_url + _extended_url
		if page_size != 0:
			url += "?pageSize=" + str(page_size)
		if page_token != "":
			url += "&pageToken=" + page_token
		if order_by != "":
			url += "&orderBy=" + order_by

		firestore_task.data = [path, page_size, page_token, order_by]
		firestore_task._url = url
		firestore_task._headers = PackedStringArray([_AUTHORIZATION_HEADER + auth.idtoken])
		_pooled_request(firestore_task)
		return firestore_task
	else:
		printerr("Unauthorized")
		return null

func set_networking(value: bool) -> void:
	if value:
		enable_networking()
	else:
		disable_networking()

func enable_networking() -> void:
	if networking:
		return
	networking = true
	_base_url = _base_url.replace("storeoffline", "firestore")
	for key in collections:
		collections[key]._base_url = _base_url

func disable_networking() -> void:
	if not networking:
		return
	networking = false
	_base_url = _base_url.replace("firestore", "storeoffline")
	for key in collections:
		collections[key]._base_url = _base_url

# @tool safe offline setter
func _set_offline(value: bool) -> void:
	_offline = value
	if Engine.is_editor_hint():
		return
	call_deferred("_set_offline_runtime", value)

# runtime-only file/cache operations
func _set_offline_runtime(value: bool) -> void:
	if not persistence_enabled:
		return

	var event_record_path = _config["cacheLocation"].path_join(_CACHE_RECORD_FILE)

	if not value:
		var offline_time = 2147483647

		# --- READ encrypted event record file ---
		var file := FileAccess.open_encrypted_with_pass(event_record_path, FileAccess.READ, _encrypt_key)
		if file != null:
			var raw := file.get_buffer(file.get_length())
			offline_time = int(raw.get_string_from_utf8()) - 2
			file.close()

		# --- Scan cache directory ---
		var cache_dir := DirAccess.open(_cache_loc)
		var cache_files: Array = []

		if cache_dir:
			cache_dir.list_dir_begin()
			var file_name = cache_dir.get_next()
			while file_name != "":
				if not cache_dir.current_is_dir() and file_name.ends_with(_CACHE_EXTENSION):
					var fullpath = _cache_loc.path_join(file_name)
					if FileAccess.get_modified_time(fullpath) >= offline_time:
						cache_files.append(fullpath)
				file_name = cache_dir.get_next()
			cache_dir.list_dir_end()

		# Skip event record file
		cache_files.erase(event_record_path)

		# --- Read and process cached docs ---
		for cache in cache_files:
			var deleted := false
			var f := FileAccess.open_encrypted_with_pass(cache, FileAccess.READ, _encrypt_key)

			if f != null:
				var name := f.get_line()
				var content := f.get_line()

				var collection_id := name.left(name.rfind("/"))
				var document_id := name.substr(name.rfind("/") + 1)

				var coll = collection(collection_id)

				if content == "--deleted--":
					coll.delete(document_id)
					deleted = true
				else:
					var json_conv := JSON.new()
					var parse_error := json_conv.parse(content)

					if parse_error == OK:
						var data = json_conv.data
						coll.update(document_id, FirestoreDocument.fields2dict(data))
					else:
						printerr("JSON Parse Error for cached document %s: %s (line %d)" % [
							document_id,
							json_conv.get_error_message(),
							json_conv.get_error_line()
						])
				f.close()
			else:
				printerr("Failed to retrieve cache %s! Error code: %d" % [cache, FileAccess.get_open_error()])

			if deleted:
				DirAccess.remove_absolute(cache)

	else:
		var f := FileAccess.open_encrypted_with_pass(event_record_path, FileAccess.WRITE, _encrypt_key)
		if f != null:
			f.store_buffer(str(Time.get_unix_time_from_system()).to_utf8_buffer())
			f.close()


func _set_config(config_json) -> void:
	_config = config_json
	_cache_loc = _config["cacheLocation"]
	_extended_url = _extended_url.replace("[PROJECT_ID]", _config.projectId)

	if not Engine.is_editor_hint():
		var record_path = _cache_loc.path_join(_CACHE_RECORD_FILE)
		_offline = FileAccess.file_exists(record_path)

func _pooled_request(task) -> void:
	if _offline:
		task._on_request_completed(HTTPRequest.RESULT_CANT_CONNECT, 404, PackedStringArray(), PackedByteArray())
		return

	var http_request
	for request in _http_request_pool:
		if not request.get_meta("requesting"):
			http_request = request
			break

	if not http_request:
		http_request = HTTPRequest.new()
		http_request.timeout = 5
		_http_request_pool.append(http_request)
		add_child(http_request)
		http_request.connect("request_completed", Callable(self, "_on_pooled_request_completed").bind(http_request))

	http_request.set_meta("requesting", true)
	http_request.set_meta("lifetime", 0.0)
	http_request.set_meta("task", task)
	http_request.request(task._url, task._headers, true, task._method, task._fields)

func _on_listed_documents(listed_documents):
	emit_signal("listed_documents", listed_documents)

func _on_result_query(result):
	emit_signal("result_query", result)

func _on_error(code, status, message):
	emit_signal("error", code, status, message)
	printerr(message)

func _on_FirebaseAuth_login_succeeded(auth_result) -> void:
	auth = auth_result
	for key in collections:
		collections[key].auth = auth

func _on_FirebaseAuth_token_refresh_succeeded(auth_result) -> void:
	auth = auth_result
	for key in collections:
		collections[key].auth = auth

func _on_pooled_request_completed(result, response_code, headers, body, request) -> void:
	request.get_meta("task")._on_request_completed(result, response_code, headers, body)
	request.set_meta("requesting", false)

func _on_connect_check_request_completed(result, _response_code, _headers, _body) -> void:
	_set_offline(result != HTTPRequest.RESULT_SUCCESS)

func _on_FirebaseAuth_logout() -> void:
	auth = {}
