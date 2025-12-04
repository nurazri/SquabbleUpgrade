extends Node2D

signal game_loaded
signal game_saved

signal currency_saved
signal achievement_saved

const _PLAYER_DATA_SAVE_PATH: String = "user://save_"
const _PLAYER_ACHIEVEMENT_PATH: String = "user://achievement_"
const _PLAYER_CURRENCY_PATH: String = "user://currency_"
const _CURRENT_LOGINS_SAVE_PATH: String = "user://logins"

# value from Firestore
const project_id: = "squabble-5848595"
const firestore_url: = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % project_id

var current_slot: int = 0

@onready var default_player_data: Dictionary = $PlayerData.default_player_data.duplicate(true)
@onready var player_data: Dictionary = $PlayerData.default_player_data.duplicate(true)
@onready var default_achievement_data: Dictionary = $PlayerData.default_player_achievements.duplicate(true)
@onready var achievement_data: Dictionary = $PlayerData.default_player_achievements.duplicate(true)
@onready var current_logins_data: Dictionary = $PlayerData.current_logins_data.duplicate(true)
@onready var default_player_document_data: Dictionary = $PlayerData.default_player_document.duplicate(true)


#Login Data
func save_logins() -> void:
	JSONLoader.save_json(current_logins_data, _CURRENT_LOGINS_SAVE_PATH)
	print("[GameLoader] saved logins: " + str(GameLoader.current_logins_data))


func load_logins() -> void:
	current_logins_data = JSONLoader.load_json(_CURRENT_LOGINS_SAVE_PATH)
	print("\n[GameLoader] loaded logins: " + str(GameLoader.current_logins_data) + "\n")


func get_login_status(key: String) -> bool:
	if current_logins_data.has(key):
		return current_logins_data[key]
	return false


func set_login_status(key: String, is_logged_in: bool) -> void:	
	current_logins_data[key] = is_logged_in
	save_logins()


#Achievement Data
func save_achievement() -> void:
	JSONLoader.save_json((achievement_data), _PLAYER_ACHIEVEMENT_PATH + str(current_slot))
	emit_signal("achievement_saved")


func load_achievement() -> void:
	var loadedAchievements: Dictionary = JSONLoader.load_json(_PLAYER_ACHIEVEMENT_PATH + str(current_slot))
	if not loadedAchievements.is_empty():
		achievement_data = JSONLoader.load_json(_PLAYER_ACHIEVEMENT_PATH + str(current_slot))
		#print("[GameLoader] achievement data loaded! " + str(GameLoader.achievement_data))
	else:
		#print("[GameLoader] achievement data loaded but empty! " + str(GameLoader.achievement_data))
		save_achievement()


func update_achievement_value(key1: String, key2: String, value) -> void:
	achievement_data[key1][key2] += value


func update_achievement_reward_status(key1: String, key2: String, key3: String, value) -> void:
	achievement_data[key1][key2][key3] = value
	match key3:
		"1": save_currency("coins", achievement_data[key1]["rewardamount"]["1"])
		"2": save_currency("diamonds", achievement_data[key1]["rewardamount"]["2"])
		"3": 
			var get_avatar: String = str(achievement_data[key1]["rewardamount"]["3"])
			player_data["owned_avatars"][get_avatar] = 1
			save_game()


func overwrite_achievement_value() -> void:
	save_achievement()


func check_achievement_parity(data: Dictionary = achievement_data) -> void:
	for d in default_achievement_data:
		if not data.has(d):
			data[d] = default_achievement_data[d]
		for a in default_achievement_data[d]:
			if not data[d].has(a):
				data[d][a] = default_achievement_data[d][a]
	
	
	for p in data.keys():
		if not default_achievement_data.has(p):	
			data.erase(p)
		if default_achievement_data.has(p):
			for a in data[p].keys():
				if not default_achievement_data[p].has(a):
					data[p].erase(a)
	
	achievement_data = data
	
	for p in achievement_data:
		for i in range(1,4):
			if achievement_data[p]["requirement"][str(i)] != default_achievement_data[p]["requirement"][str(i)]:
				achievement_data[p]["requirement"][str(i)] = default_achievement_data[p]["requirement"][str(i)]
		
		if achievement_data[p]["rewardamount"]["3"] != default_achievement_data[p]["rewardamount"]["3"]:
			achievement_data[p]["rewardamount"]["3"] = default_achievement_data[p]["rewardamount"]["3"]
	
	save_achievement()
	
	
func clear_achievement() -> void:
	for p in achievement_data:
		achievement_data.erase(p)
	
	achievement_data = default_achievement_data
	save_achievement()


#Game Data
func delete_game() -> bool:
	var removed: bool = false
	var filepath = DirAccess.new()
	var check_if_exists: bool = filepath.file_exists(_PLAYER_DATA_SAVE_PATH + str(current_slot))
	print(check_if_exists)
	print(_PLAYER_DATA_SAVE_PATH + str(current_slot))
	if check_if_exists:
		filepath.remove(_PLAYER_DATA_SAVE_PATH + str(current_slot))
		filepath.remove(_PLAYER_ACHIEVEMENT_PATH + str(current_slot))
		filepath.remove(_PLAYER_CURRENCY_PATH + str(current_slot))
		removed = true
	return removed


func save_game() -> void:
	JSONLoader.save_json(player_data, _PLAYER_DATA_SAVE_PATH + str(current_slot))
	emit_signal("game_saved")
	print("[GameLoader] player data saved! " + str(GameLoader.player_data) + "\n")


func save_game_without_signal() -> void:
	JSONLoader.save_json(player_data, _PLAYER_DATA_SAVE_PATH + str(current_slot))
	#print("[GameLoader] player data saved! " + str(GameLoader.player_data) + "\n")


func load_game() -> void:
	var loaded: Dictionary = _load_game()	
	if not loaded.is_empty():
		player_data = _load_game()
		emit_signal("game_loaded")
		print("[GameLoader] player data loaded! " + str(GameLoader.player_data) + "\n")
	else:
		print("[GameLoader] player data loaded but empty! " + str(GameLoader.player_data) + "\n")
		save_game()


func save_data(key: String, value) -> void:
	set_save_data(key, value)
	save_game()


# Varying return type
func load_data(key: String):
	load_game()
	return player_data[key]


func set_save_data(key: String, value) -> void:
	player_data[key] = value


func set_level_progression_data(level: int, rating: int, override_next: bool = true) -> void:
	player_data["level_progression"][str(level)]["completion"] = 2
	player_data["level_progression"][str(level)]["rating"] = rating
	
	if override_next:
		if player_data["level_progression"][str(level+1)]["completion"] == 0:
			player_data["current_level"] = (level+1)
			player_data["level_progression"][str(level+1)]["completion"] = 1
	
	save_game()


# Varying return type
func get_save_data(key: String):
	if player_data.has(key):
		return player_data[key]
	return null


func check_keys_parity(data: Dictionary = player_data, _default_player_data: Dictionary = default_player_data) -> void:
	for d in _default_player_data:
		if not data.has(d):
			data[d] = _default_player_data[d]
	
	for p in data:
		if not _default_player_data.has(p):
			data.erase(p)
	
	merge_dict(data, default_player_data)
	player_data = data
	GameLoader.save_game()


func _load_game() -> Dictionary:
	return JSONLoader.load_json(_PLAYER_DATA_SAVE_PATH + str(current_slot))


func _load_currency() -> Dictionary:
	return JSONLoader.load_json(_PLAYER_CURRENCY_PATH + str(current_slot))


#Currency
func save_currency(key: String, value) -> void:
	default_player_document_data[key] += value
	JSONLoader.save_json(default_player_document_data, _PLAYER_CURRENCY_PATH + str(current_slot))
	emit_signal("currency_saved")
	print("[GameLoader] player currency saved!")


func load_currency(key: String):
	if JSONLoader.load_json(_PLAYER_CURRENCY_PATH + str(current_slot)).is_empty():
		if default_player_document_data.has(key):
			return default_player_document_data[key]
	else :
		default_player_document_data = JSONLoader.load_json(_PLAYER_CURRENCY_PATH + str(current_slot))
		return default_player_document_data[key]


static func merge_dict(dest, source):
	for key in source:                     # go via all keys in source
		if dest.has(key):                  # we found matching key in dest
			var dest_value = dest[key]     # get value 
			var source_value = source[key] # get value in the source dict           
			if typeof(dest_value) == TYPE_DICTIONARY:       
				if typeof(source_value) == TYPE_DICTIONARY: 
					merge_dict(dest_value, source_value)  
				else:
					dest[key] = dest_value # override the dest value
			else:
				dest[key] = dest_value     # add to dictionary 
		else:
			dest[key] = source[key]          # just add value to the dest
