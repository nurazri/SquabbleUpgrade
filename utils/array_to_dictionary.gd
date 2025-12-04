extends Node2D

const _PATH_TO_SCRABBLE_WORD_LIST: String = "res://word_list/dictionary.json"
const _PATH_TO_OUTPUT: String = "res://word_list/words_dictionary_squabble.json"


func _ready() -> void:
	var _word_list = JSONLoader.load_json(_PATH_TO_SCRABBLE_WORD_LIST)
	var _word_dictionary: Dictionary = {}
	for word in _word_list:
		_word_dictionary[word] = 1
		
	JSONLoader.save_json(_word_dictionary, _PATH_TO_OUTPUT)
	get_tree().quit()
