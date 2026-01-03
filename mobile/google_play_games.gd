extends Node

signal signed_in
signal signed_in_failed
signal signed_out
signal signed_out_failed
signal game_saved
signal game_saved_failed
signal game_loaded
signal game_loaded_failed
signal player_info_loaded
signal player_info_loaded_failed

var is_signed_in: bool: get = _is_signed_in
var loaded_data: Dictionary = {}
var player_info: Dictionary = {}

var _play_games_services = null


func _ready() -> void:
	if OS.get_name() == "Android":
		_connect_signals()
		_init()
		print("[GooglePlayGames] isGooglePlayServicesAvailable: " + str(_play_games_services.isGooglePlayServicesAvailable()))


func sign_in() -> void:
	if _play_games_services:
		_play_games_services.signIn()

func sign_out() -> void:
	if _play_games_services and is_signed_in:
		_play_games_services.signOut()
	else:
		print("GPGS: signOut skipped (not signed in)")
		
func _on_play_games_sign_in_success():
	is_signed_in = true

func _on_play_games_sign_out_success():
	is_signed_in = false



func save_game(snapshot_name: String = "SquabbleSave", data: Dictionary = GameLoader.player_data, description: String = "Squabble save.") -> void:
	if _play_games_services:
		_play_games_services.saveSnapshot(snapshot_name, JSON.new().stringify(data), description)
		
		
func load_game(snapshot_name: String = "SquabbleSave") -> void:
	print("[GooglePlayGames] trying to load game from Google Play Games Services!")
	if _play_games_services:
		_play_games_services.loadSnapshot(snapshot_name)


func achievement_unlocked(achievement_id: String) -> void:
	if _play_games_services:
		_play_games_services.unlockAchievement(achievement_id)


func _is_signed_in() -> bool:
	if _play_games_services:
		return _play_games_services.isSignedIn()
	return false


func _init() -> void:
	if Engine.has_singleton("GodotPlayGamesServices"):
		_play_games_services = Engine.get_singleton("GodotPlayGamesServices")
#		_play_games_services.init(true, false, false, "")
		_play_games_services.initWithSavedGames(true, "SquabbleSave", false, false, "")


func _connect_signals() -> void:
	if _play_games_services:
		_play_games_services.connect("_on_sign_in_success", Callable(self, "_on_sign_in_success"))
		_play_games_services.connect("_on_sign_in_failed", Callable(self, "_on_sign_in_failed"))
		
		_play_games_services.connect("_on_sign_out_success", Callable(self, "_on_sign_out_success")) 
		_play_games_services.connect("_on_sign_out_failed", Callable(self, "_on_sign_out_failed"))
		
		_play_games_services.connect("_on_game_saved_success", Callable(self, "_on_game_saved_success")) # no params
		_play_games_services.connect("_on_game_saved_fail", Callable(self, "_on_game_saved_fail")) # no params
		_play_games_services.connect("_on_game_load_success", Callable(self, "_on_game_load_success")) # data: String
		_play_games_services.connect("_on_game_load_fail", Callable(self, "_on_game_load_fail")) # no params
		
		_play_games_services.connect("_on_player_info_loaded", Callable(self, "_on_player_info_loaded"))  # json_response: String
		_play_games_services.connect("_on_player_info_loading_failed", Callable(self, "_on_player_info_loading_failed"))

		_play_games_services.connect("_on_achievement_unlocked", Callable(self, "_on_achievement_unlocked")) # achievement: String
		_play_games_services.connect("_on_achievement_unlocking_failed", Callable(self, "_on_achievement_unlocking_failed")) # achievement: String


func _on_sign_in_success(_data: String) -> void:
	_play_games_services.loadPlayerInfo()
	emit_signal("signed_in")
	print("[GooglePlayGames] sign in successful!" + str(_data))
	
	# Set google ID into the device
	var dataArray = _data.split(":")
	FirebaseFirestoreDocument.auth_value.googleId = dataArray[1]
	
	# connect to Firebase
	Firebase.Auth.login_anonymous()
	
	# var outh_token : String
	# Firebase.Auth.login_with_oauth(outh_token)

func _on_sign_in_failed(error_code: int) -> void:
	emit_signal("signed_in_failed")
	print("[GooglePlayGames] sign in failed! Error code: " + str(error_code))


func _on_sign_out_success() -> void:
	emit_signal("signed_out")
	print("[GooglePlayGames] sign out successful!")
	
	
func _on_sign_out_failed() -> void:
	emit_signal("signed_out_failed")
	print("[GooglePlayGames] sign out failed!")
	
	
func _on_game_saved_success() -> void:
	emit_signal("game_saved")
	print("[GooglePlayGames] game successfully saved!")
	
	
func _on_game_saved_fail() -> void:
	emit_signal("game_saved_failed")
	print("[GooglePlayGames] game failed to save!")
	
	
func _on_game_load_success(data: String) -> void:
	if data:
		var test_json_conv = JSON.new()
		test_json_conv.parse(data)
		loaded_data = test_json_conv.get_data()
	if not loaded_data.is_empty():
		emit_signal("game_loaded", loaded_data)
		print("[GooglePlayGames] game successfully loaded! " + str(loaded_data))
	else:
		emit_signal("game_loaded_failed")
		print("[GooglePlayGames] game loaded but saved data not found!")
	
	
func _on_game_load_fail() -> void:
	emit_signal("game_loaded_failed")
	print("[GooglePlayGames] game failed to load!")
	
	
func _on_player_info_loaded(info: String) -> void:
	var test_json_conv = JSON.new()
	test_json_conv.parse(info)
	player_info = test_json_conv.get_data()
	# Using below keys you can retrieve player’s info
	#	info_dictionary["display_name"]
	#	info_dictionary["name"]
	#	info_dictionary["title"]
	#	info_dictionary["player_id"]
	#	info_dictionary["hi_res_image_url"]
	#	info_dictionary["icon_image_url"]
	#	info_dictionary["banner_image_landscape_url"]
	#	info_dictionary["banner_image_portrait_url"]
	emit_signal("player_info_loaded")
	print("[GooglePlayGames] player info successfully loaded!")
#	print(player_info)
	
	
func _on_player_info_loading_failed() -> void:
	emit_signal("player_info_loaded_failed")
	print("[GooglePlayGames] player info failed to load!")


func _on_achievement_unlocked(achievement: String) -> void:
	print("[GooglePlayGames] achievement " + achievement + " unlocked!")


func _on_achievement_unlocking_failed(achievement: String) -> void:
	print("[GooglePlayGames] achievement " + achievement + " failed to unlock!")
