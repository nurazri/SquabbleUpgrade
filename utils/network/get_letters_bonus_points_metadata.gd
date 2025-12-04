extends Node2D

const _PATH_TO_LETTERS_METADATA_JSON: String = "res://word_list/letters_bonus_points_metadata.json"
const _GSHEETS_LETTERS_JSON: String = "http://spreadsheets.google.com/feeds/cells/1-Tr0f2UTcXFP2TCu0IX4XkNKa-J6xpjaNLUThmy_6PU/4/public/full?alt=json"

func _ready() -> void:
	var HttpRequest: HTTPRequest = HTTPRequest.new()
	add_child(HttpRequest)
	if not HttpRequest.is_connected("request_completed", Callable(self, "_on_HttpRequest_request_completed")):
		# warning-ignore:return_value_discarded
		HttpRequest.connect("request_completed", Callable(self, "_on_HttpRequest_request_completed"))
	
	# warning-ignore:return_value_discarded
	if not HttpRequest.request(_GSHEETS_LETTERS_JSON) == OK:
		print("[GetLettersBonusPointsMetadata] error! Can't connect to Google Sheets!")

	
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HttpRequest_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var json: JSON = test_json_conv.get_data()
	
	if json.result:	
		var data: Array = json.result.feed.entry		
		var dict: Dictionary = {}
		
		for i in range(2, data.size(), 2):
			if i + 1 < data.size():
				var letter_count: int = data[i]["gs$cell"].inputValue as int
				var bonus_points: int = data[i + 1]["gs$cell"].inputValue as int
				
				dict[letter_count] = {
					"points_letter_bonus": bonus_points
				}
		
		var file: File = File.new()
		if file.open(_PATH_TO_LETTERS_METADATA_JSON, file.WRITE) != OK: return
		file.store_string(JSON.stringify(dict))
		print("Updated letters_bonus_points_metadata.json!")
