extends Node2D
	

func load_json(path: String) -> Dictionary:
	#var file: File = File.new()
	#if file.open(path, file.READ) != OK: return {}
	#var test_json_conv = JSON.new()
	#test_json_conv.parse(file.get_as_text())
	#return test_json_conv.get_data()
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	var data : Dictionary  = JSON.parse_string(text)
	if data == null:
		return {}

	return data

	
func save_json(dict: Dictionary, path: String) -> void:
	#var file: File = File.new()
	#if file.open(path, file.WRITE) != OK: return
	#file.store_string(JSON.stringify(dict))
	#return
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify(dict))
	file.close()
