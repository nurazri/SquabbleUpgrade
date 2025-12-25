class_name GameLoaderManager
extends Node2D

signal game_loaded
signal game_saved
signal achievement_saved
signal currency_updated

const _PLAYER_DATA_SAVE_PATH: String = "save_"
const _PLAYER_ACHIEVEMENT_PATH: String = "achievement_"
const _PLAYER_CURRENCY_PATH: String = "currency_"
const _CURRENT_LOGINS_SAVE_PATH: String = "logins"

const project_id: String = "squabble-5848595"
const firestore_url: String = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % project_id

var current_slot: int = 0

@onready var default_player_data: Dictionary = $PlayerData.default_player_data.duplicate(true)
@onready var player_data: Dictionary = $PlayerData.default_player_data.duplicate(true)
@onready var default_achievement_data: Dictionary = $PlayerData.default_player_achievements.duplicate(true)
@onready var achievement_data: Dictionary = $PlayerData.default_player_achievements.duplicate(true)
@onready var current_logins_data: Dictionary = $PlayerData.current_logins_data.duplicate(true)
@onready var default_player_document_data: Dictionary = $PlayerData.default_player_document.duplicate(true)

# -------------------- Login Data --------------------
func save_logins() -> void:
	JSONLoader.save_json(current_logins_data, _CURRENT_LOGINS_SAVE_PATH)

func load_logins() -> void:
	current_logins_data = JSONLoader.load_json(_CURRENT_LOGINS_SAVE_PATH)

func get_login_status(key: String) -> bool:
	return current_logins_data.get(key, false)

func set_login_status(key: String, is_logged_in: bool) -> void:
	current_logins_data[key] = is_logged_in
	save_logins()

# -------------------- Achievement Data --------------------
func save_achievement() -> void:
	JSONLoader.save_json(achievement_data, _PLAYER_ACHIEVEMENT_PATH + str(current_slot))
	emit_signal("achievement_saved")

func load_achievement() -> void:
	var loadedAchievements: Dictionary = JSONLoader.load_json(_PLAYER_ACHIEVEMENT_PATH + str(current_slot))
	if not loadedAchievements.is_empty():
		achievement_data = loadedAchievements
		check_achievement_parity(achievement_data)
	else:
		achievement_data = default_achievement_data.duplicate(true)
		save_achievement()

func update_achievement_value(key1: String, key2: String, value) -> void:
	if achievement_data.has(key1) and achievement_data[key1].has(key2):
		achievement_data[key1][key2] += value
		save_achievement()

func update_achievement_reward_status(key1: String, key2: String, key3: String, value) -> void:
	if not achievement_data.has(key1):
		return
	achievement_data[key1][key2][key3] = value
	match key3:
		"1": save_currency("coins", achievement_data[key1]["rewardamount"]["1"])
		"2": save_currency("diamonds", achievement_data[key1]["rewardamount"]["2"])
		"3":
			var avatar_id: String = str(achievement_data[key1]["rewardamount"].get("3", ""))
			if avatar_id != "":
				player_data["owned_avatars"][avatar_id] = 1
				save_game()
		_: pass

func overwrite_achievement_value() -> void:
	save_achievement()

func check_achievement_parity(data: Dictionary = achievement_data) -> void:
	# Ensure all keys exist as in default
	for k in default_achievement_data.keys():
		if not data.has(k):
			data[k] = default_achievement_data[k].duplicate(true)
		else:
			for sub in default_achievement_data[k].keys():
				if not data[k].has(sub):
					data[k][sub] = default_achievement_data[k][sub]
	# Remove extra keys
	for k in data.keys():
		if not default_achievement_data.has(k):
			data.erase(k)
	achievement_data = data
	save_achievement()

func clear_achievement() -> void:
	achievement_data = default_achievement_data.duplicate(true)
	save_achievement()

# -------------------- Game Data --------------------
func delete_game() -> bool:
	var removed: bool = false
	var save_path := _PLAYER_DATA_SAVE_PATH + str(current_slot)
	var ach_path := _PLAYER_ACHIEVEMENT_PATH + str(current_slot)
	var cur_path := _PLAYER_CURRENCY_PATH + str(current_slot)
	var dir := DirAccess.open("user://")
	if dir:
		if FileAccess.file_exists("user://%s" % save_path):
			dir.remove(save_path)
			dir.remove(ach_path)
			dir.remove(cur_path)
			removed = true
	return removed

func save_game() -> void:
	JSONLoader.save_json(player_data, _PLAYER_DATA_SAVE_PATH + str(current_slot))
	emit_signal("game_saved")

func save_game_without_signal() -> void:
	JSONLoader.save_json(player_data, _PLAYER_DATA_SAVE_PATH + str(current_slot))

func load_game() -> void:
	var loaded: Dictionary = _load_game()
	if not loaded.is_empty():
		player_data = loaded
		emit_signal("game_loaded")
	else:
		player_data = default_player_data.duplicate(true)
		save_game()

func save_data(key: String, value) -> void:
	player_data[key] = value
	save_game()

func load_data(key: String):
	load_game()
	return player_data.get(key, null)

func set_level_progression_data(level: int, rating: int, override_next: bool = true) -> void:
	var level_key := str(level)
	player_data["level_progression"][level_key]["completion"] = 2
	player_data["level_progression"][level_key]["rating"] = rating

	if override_next:
		var next_key := str(level + 1)
		if player_data["level_progression"].has(next_key):
			if player_data["level_progression"][next_key]["completion"] == 0:
				player_data["current_level"] = (level + 1)
				player_data["level_progression"][next_key]["completion"] = 1
	save_game()

func check_keys_parity(data: Dictionary = player_data, default_data: Dictionary = default_player_data) -> void:
	# Add missing keys
	for k in default_data.keys():
		if not data.has(k):
			data[k] = default_data[k].duplicate(true)
		elif typeof(data[k]) == TYPE_DICTIONARY and typeof(default_data[k]) == TYPE_DICTIONARY:
			check_keys_parity(data[k], default_data[k]) # safe recursion
	# Remove extra keys
	for k in data.keys():
		if not default_data.has(k):
			data.erase(k)
	player_data = data
	save_game()

func _load_game() -> Dictionary:
	return JSONLoader.load_json(_PLAYER_DATA_SAVE_PATH + str(current_slot))

# -------------------- Currency --------------------
func save_currency(key: String, value) -> void:
	default_player_document_data[key] = default_player_document_data.get(key, 0) + value
	JSONLoader.save_json(default_player_document_data, _PLAYER_CURRENCY_PATH + str(current_slot))
	emit_signal("currency_updated")

func load_currency(key: String):
	var loaded := JSONLoader.load_json(_PLAYER_CURRENCY_PATH + str(current_slot))
	if loaded.is_empty():
		return default_player_document_data.get(key, 0)
	default_player_document_data = loaded
	return default_player_document_data.get(key, 0)

# -------------------- Utilities --------------------
static func merge_dict(dest: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		var source_value = source[key]
		if dest.has(key):
			var dest_value = dest[key]
			if typeof(dest_value) == TYPE_DICTIONARY and typeof(source_value) == TYPE_DICTIONARY:
				merge_dict(dest_value, source_value)
			# do NOT overwrite non-dict values to prevent recursion
		else:
			dest[key] = source_value

func set_slot(slot: int) -> void:
	current_slot = max(0, slot)
	
func get_save_data(key: String):
	if player_data.has(key):
		return player_data[key]
	return null
