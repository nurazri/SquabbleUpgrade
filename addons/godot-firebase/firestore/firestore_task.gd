@tool
class_name FirestoreTask
extends RefCounted

signal task_finished(result)
signal add_document(doc)
signal get_document(doc)
signal update_document(doc)
signal delete_document()
signal listed_documents(documents)
signal result_query(result)
signal error(error)

enum Task {
	TASK_GET,
	TASK_POST,
	TASK_PATCH,
	TASK_DELETE,
	TASK_QUERY,
	TASK_LIST
}

var action: int = -1
var data
var from_cache: bool = false

var _response_headers : PackedStringArray = PackedStringArray()
var _response_code : int = 0

var _method : int = -1
var _url : String = ""
var _fields : String = ""
var _headers : PackedStringArray = PackedStringArray()


func _on_request_completed(result : int, response_code : int, headers : PackedStringArray, body : PackedByteArray) -> void:
	_response_headers = headers
	_response_code = response_code

	var body_text := ""
	if body.size() > 0:
		body_text = body.get_string_from_utf8()

	var bod = null
	if body_text != "":
		var json = JSON.new()
		if json.parse(body_text) == OK:
			bod = json.get_data()
		else:
			bod = body_text

	var offline := bod == null
	var is_error: bool = (bod is Dictionary and bod.has("error")) and response_code != HTTPClient.RESPONSE_OK

	from_cache = offline

	Firebase.Firestore._set_offline(offline)

	var cache_path : String = Firebase._config["cacheLocation"]
	if cache_path != "" and not is_error and Firebase.Firestore.persistence_enabled:
		var encrypt_key : String = Firebase.Firestore._encrypt_key
		var full_path : String
		var url_segment : String

		match action:
			Task.TASK_LIST:
				url_segment = data[0]
				full_path = cache_path
			Task.TASK_QUERY:
				url_segment = JSON.stringify(data.query)
				full_path = cache_path
			_:
				url_segment = data
				full_path = _get_doc_file(cache_path, url_segment, encrypt_key)

		bod = _handle_cache(offline, data, encrypt_key, full_path, bod)
		if bod is Dictionary and offline:
			response_code = HTTPClient.RESPONSE_OK

	if response_code == HTTPClient.RESPONSE_OK:
		match action:
			Task.TASK_POST:
				data = FirestoreDocument.new(bod)
				emit_signal("add_document", data)

			Task.TASK_GET:
				data = FirestoreDocument.new(bod)
				emit_signal("get_document", data)

			Task.TASK_PATCH:
				data = FirestoreDocument.new(bod)
				emit_signal("update_document", data)

			Task.TASK_DELETE:
				data = null
				emit_signal("delete_document")

			Task.TASK_QUERY:
				data = bod
				emit_signal("result_query", bod)

			Task.TASK_LIST:
				data = []
				for doc in bod.documents:
					data.append(FirestoreDocument.new(doc))

				if bod.has("nextPageToken"):
					data.append(bod.nextPageToken)

				emit_signal("listed_documents", data)

	else:
		match action:
			Task.TASK_LIST, Task.TASK_QUERY:
				data = bod[0].error
				emit_signal("error", data)
			_:
				data = bod.error
				emit_signal("error", data)

	emit_signal("task_finished", data)


func set_action(value : int) -> void:
	action = value
	match action:
		Task.TASK_GET, Task.TASK_LIST:
			_method = HTTPClient.METHOD_GET
		Task.TASK_POST, Task.TASK_QUERY:
			_method = HTTPClient.METHOD_POST
		Task.TASK_PATCH:
			_method = HTTPClient.METHOD_PATCH
		Task.TASK_DELETE:
			_method = HTTPClient.METHOD_DELETE


func _handle_cache(offline : bool, data, encrypt_key : String, cache_path : String, body) -> Dictionary:
	var body_return : Dictionary = {}

	var dir := DirAccess.open(cache_path)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(cache_path)
		dir = DirAccess.open(cache_path)

	var file_path := cache_path
	var file : FileAccess

	match action:

		Task.TASK_GET:
			if offline:
				if FileAccess.file_exists(cache_path):
					file = FileAccess.open_encrypted_with_pass(cache_path, FileAccess.READ, encrypt_key)
					if file:
						var id = file.get_line()
						var content = file.get_line()
						if content != "--deleted--":
							var json = JSON.new()
							json.parse(content)
							body_return = json.get_data()
						file.close()

		Task.TASK_DELETE:
			if offline:
				file = FileAccess.open_encrypted_with_pass(cache_path, FileAccess.WRITE, encrypt_key)
				if file:
					file.store_line(data)
					file.store_line("--deleted--")
					file.close()
					body_return = {"deleted": true}
			else:
				DirAccess.remove_absolute(cache_path)

		Task.TASK_POST, Task.TASK_PATCH:
			var save := {}
			if offline:
				var json = JSON.new()
				json.parse(_fields)
				save = {
					"name": "projects/%s/databases/(default)/documents/%s" % [Firebase._config["storageBucket"], data],
					"fields": json.get_data()["fields"],
					"createTime": "from_cache",
					"updateTime": "from_cache"
				}
			else:
				save = body.duplicate()

			file = FileAccess.open_encrypted_with_pass(cache_path, FileAccess.WRITE, encrypt_key)
			if file:
				file.store_line(data)
				file.store_line(JSON.stringify(save))
				file.close()

			body_return = save

		Task.TASK_LIST:
			if offline:
				body_return = {"documents": [], "nextPageToken": ""}

		Task.TASK_QUERY:
			if offline:
				push_error("Offline query unsupported.")

	return body if not offline else body_return


func _merge_dict(a : Dictionary, b : Dictionary, nullify := false) -> Dictionary:
	var res = a.duplicate(true)
	for key in b.keys():
		var val = b[key]
		if val == null and nullify:
			res.erase(key)
		elif val is Dictionary:
			var existing = res.has(key) and res[key] is Dictionary if res.has(key) and res[key] is Dictionary else {}
			res[key] = _merge_dict(existing, val, nullify)
		elif val is Array:
			var existing = res.has(key) and res[key] is Array if res.has(key) and res[key] is Array else []
			res[key] = _merge_array(existing, val, nullify)
		else:
			res[key] = val
	return res


func _merge_array(a : Array, b : Array, nullify := false) -> Array:
	var res = a.duplicate(true)
	res.resize(b.size())

	for i in b.size():
		var val = b[i]
		var existing
		if i < res.size():
			existing = res[i]
		else:
			existing = {} if val is Dictionary else ([] if val is Array else null)

		if val == null and nullify:
			if i < res.size():
				res.remove_at(i)
		elif val is Dictionary:
			res[i] = _merge_dict(existing, val, nullify)
		elif val is Array:
			res[i] = _merge_array(existing, val, nullify)
		else:
			res[i] = val
	return res


static func _get_doc_file(cache_path : String, document_id : String, encrypt_key : String) -> String:
	var hash_str := str(document_id.hash()).pad_zeros(10)
	for i in 256:
		var file_path := cache_path + "/%s-%d.fscache" % [hash_str, i]
		if not FileAccess.file_exists(file_path):
			return file_path

		var file := FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, encrypt_key)
		if file:
			if file.get_line() == document_id:
				file.close()
				return file_path
			file.close()

	return cache_path + "/%s-0.fscache" % hash_str
