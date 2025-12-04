extends Node2D

signal word_list_reset

const VOWELS: Array = ["A", "E", "I", "O", "U"]

const _PATH_TO_WORD_LIST: String = "res://word_list/words_dictionary_squabble.json"
const _PATH_TO_LETTERS_METADATA_TEMP: String = "res://word_list/letters_metadata_temp.json"
const _PATH_TO_LETTERS_BONUS_POINTS_METADATA: String = "res://word_list/letters_bonus_points_metadata.json"

var word_list_3: Dictionary = {}
var word_list_4: Dictionary = {}
var word_list_5: Dictionary = {}
var word_list_6: Dictionary = {}
var word_list_7: Dictionary = {}
var word_list_8: Dictionary = {}

var word_list: Dictionary = {}

var letters_metadata: Dictionary = {}
var letters_keys: Array = []
var letters_bonus_points_metadata: Dictionary = {}
var spawned_letters: Dictionary = {}

var _word_list: Dictionary = {}
var _word_list_ai: Dictionary = {}

var _word_list_cached: Dictionary = {}
var _letters_metadata: Dictionary = {}
var _letters_metadata_cached: Dictionary = {}
var _letters_bonus_points_metadata: Dictionary = {}
var _letters_bonus_points_metadata_cached: Dictionary = {}

var current_metadata_list: String = ""

func _ready() -> void:
	_word_list = JSONLoader.load_json(_PATH_TO_WORD_LIST)
	_letters_metadata = JSONLoader.load_json(_PATH_TO_LETTERS_METADATA_TEMP)
	_letters_bonus_points_metadata = JSONLoader.load_json(_PATH_TO_LETTERS_BONUS_POINTS_METADATA)


func set_parameters(level) -> void:
	for i in Globals.OpponentList:
		if (level <= Globals.OpponentList[i]["Max_Level"] && level >= Globals.OpponentList[i]["Min_Level"]):
			_word_list_ai = JSONLoader.load_json(return_AI_dictionary(Globals.OpponentList[i]["Dictionary_Level"]))
			_letters_metadata = JSONLoader.load_json(return_level_wordlist(Globals.OpponentList[i]["Difficulty"]))
			current_metadata_list = return_level_wordlist(Globals.OpponentList[i]["Difficulty"])
			break
	reset()


func set_custom_parameters(word_mix: String, difficulty: String) -> void:
	_letters_metadata = JSONLoader.load_json(return_level_wordlist(word_mix))
	current_metadata_list = return_level_wordlist(word_mix)
	if word_mix != "professional":
		_word_list_ai = JSONLoader.load_json(return_AI_dictionary(difficulty))
	else:
		_word_list_ai = JSONLoader.load_json(_PATH_TO_WORD_LIST)
	
	reset()


func return_AI_dictionary(difficulty: String) -> String:
	return "res://word_list/words_dictionary_squabble_" + difficulty + ".json"


func return_level_wordlist(difficulty: String) -> String:
	return "res://word_list/letters_metadata_" + difficulty +".json"


func refresh() -> void:
	_letters_metadata = JSONLoader.load_json(current_metadata_list)
	letters_metadata = _letters_metadata
	letters_keys.clear()
	letters_keys = letters_metadata.keys()


func reset() -> void:
	_word_list_cached = _word_list.duplicate(true)
	_letters_metadata_cached = _letters_metadata.duplicate(true)
	_letters_bonus_points_metadata_cached = _letters_bonus_points_metadata.duplicate(true)
	_set_init(_word_list_cached, _letters_metadata_cached, _letters_bonus_points_metadata_cached)
	spawned_letters.clear()


func add_spawned_letter(letter_data: Dictionary) -> void:
	spawned_letters[letter_data["id"]] = letter_data


func remove_spawned_letter(id: int) -> bool:
	if spawned_letters.has(id):
		return spawned_letters.erase(id)
	return false


func get_spawned_letter_data(id: int) -> Dictionary:
	if spawned_letters.has(id):
		return spawned_letters[id]
	return {}


func get_if_letter_exists(id: int) -> bool:
	if spawned_letters.has(id):
		return true
	return false


func set_spawned_letter_data(id: int, key: String, value) -> bool:
	if spawned_letters.has(id):
		if spawned_letters[id].has(key):
			spawned_letters[id][key] = value
			return true
	return false


func get_spawned_letters_owned_by(ownership: int) -> Dictionary:
	if ownership == Globals.LetterOwnership.ALL:
		return spawned_letters
	var filtered: Dictionary = {}
	for i in spawned_letters:
		if spawned_letters[i]["owned_by"] == ownership:
			filtered[spawned_letters[i]["id"]] = spawned_letters[i]	
	return filtered


func get_spawned_letters_quantity_left() -> int:
	var sum: int = 0
	for l in letters_metadata:
		sum += letters_metadata[l]["quantity"]
	return sum


func get_letter_points(letter: String, fromProfile: bool = false) -> int:
	if not letters_metadata.is_empty():
		return letters_metadata[letter.to_upper()]["points_letter"]
	if fromProfile:
		var temp_letters_metadata = JSONLoader.load_json(current_metadata_list)
		return temp_letters_metadata[letter.to_upper()]["points_letter"]
		
	return -1


func get_random_letter() -> String:
	var to_spawn: String = ""
	if not WordList.letters_keys.is_empty():
		to_spawn = WordList.letters_keys[randi() % WordList.letters_keys.size()]
		while (letters_metadata[to_spawn]["quantity"] == 0):
			to_spawn = WordList.letters_keys[randi() % WordList.letters_keys.size()]
		
	return to_spawn


func decrease_letter_quantity(letter: String) -> bool:
	if not letters_metadata.is_empty():
		if letters_metadata[letter.to_upper()]["quantity"] > 0:
			letters_metadata[letter.to_upper()]["quantity"] -= 1
			if letters_metadata[letter.to_upper()]["quantity"] <= 0:
				letters_keys.erase(letter.to_upper())
			return true
	return false


func get_string_from_ids(ids: Array) -> String:
	var word: String = ""
	
	for id in ids:
		if get_if_letter_exists(id) == false:
			break
		#print(id)
		word += WordList.spawned_letters[id]["letter"]
	return word


func get_string_from_letters(letters: Array) -> String:
	var word: String = ""
	for l in letters:
		if l:
			word += WordList.spawned_letters[l.id]["letter"]
	return word


func is_valid_word(_word: String, _word_list_: Dictionary = word_list, is_ai: bool = false) -> bool:
	if is_ai:
		return _word_list_ai.has(_word.to_lower())
	else:
		return _word_list_.has(_word.to_lower())


func is_letter_vowel_at_index(letter_index: int) -> bool:
	return letters_keys[letter_index] in VOWELS
	

func get_ownership_from_letter(letter: Letter) -> int:
	return spawned_letters[letter.id]["owned_by"]


func _set_init(
			word_list_: Dictionary, 
			letters_metadata_: Dictionary, 
			letters_bonus_points_metadata_: Dictionary
		) -> void:
	word_list = word_list_
	for w in word_list:
		match w.length():
			3: word_list_3[w] = 1
			4: word_list_4[w] = 1
			5: word_list_5[w] = 1
			6: word_list_6[w] = 1
			7: word_list_7[w] = 1
			8: word_list_8[w] = 1

	letters_metadata = letters_metadata_
	letters_keys.clear()
	letters_keys = letters_metadata_.keys()
	
	letters_bonus_points_metadata = letters_bonus_points_metadata_.duplicate(true)	
	emit_signal("word_list_reset")	
	print("[WorldList] initialized!\n")
	print("[WordList] letters_keys:\n" + str(WordList.letters_keys) + "\n")
	print("[WordList] letters_metadata:\n" + str(WordList.letters_metadata) + "\n")
	print("[WordList] letters_bonus_points_metadata:\n" + str(WordList.letters_bonus_points_metadata) + "\n")
	print("")
