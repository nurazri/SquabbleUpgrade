extends Node2D

const _PATH_TO_VOWELS_LIST: String = "res://words_dictionary_vowels.json"
const _PATH_TO_CONSONANTS_LIST: String = "res://words_dictionary_consonants.json"


func get_vowels_only(word_list: Dictionary) -> Dictionary:
	var pass1: Dictionary	
	for word in word_list:
		var count: int = 0		
		for w in word:
			if _is_vowel(w):
				count += 1
		if count == word.length():
			pass1[word] = 1			
	return pass1


func get_consonants_only(word_list: Dictionary) -> Dictionary:
	var pass1: Dictionary	
	for word in word_list:
		var count: int = 0		
		for w in word:
			if not _is_vowel(w):
				count += 1
		if count == word.length():
			pass1[word] = 1	
	return pass1
	
	
func save_filtered_word_list(filtered: Dictionary, path: String) -> void:
	JSONLoader.save_json(filtered, path)


func save_vowels_to_file(word_list: Dictionary) -> void:
	save_filtered_word_list(get_vowels_only(word_list), _PATH_TO_VOWELS_LIST)


func save_consonants_to_file(word_list: Dictionary) -> void:
	save_filtered_word_list(get_consonants_only(word_list), _PATH_TO_CONSONANTS_LIST)


func _is_vowel(c: String) -> bool:
	c = c.to_lower()
	return c == "a" or c == "e" or c == "i" or c == "o" or c == "u"
	
