extends Control

signal login_checked(is_login_checked)


func _ready() -> void:
	show()
	GameLoader.current_slot = 1
	var _game_data: Dictionary = GameLoader._load_game()
	var _currency_data: Dictionary = GameLoader._load_currency()
	await get_tree().create_timer(0.01).timeout
	if _game_data.is_empty():
		create_profile(1)
	else:
		select_profile(1)


func create_profile(slot, is_expert: bool = false) -> void:
	GameLoader.current_slot = slot
	GameLoader.save_game()
	GameLoader.save_achievement()
	GameLoader.save_currency("coins", 0)
	GameLoader.save_currency("diamonds", 0)
	GameLoader.check_keys_parity()
	select_profile(slot)


func select_profile(slot) -> void:
	GameLoader.current_slot = slot
	GameLoader.load_game()
	GameLoader.check_keys_parity()
	GameLoader.load_achievement()
	GameLoader.check_achievement_parity()
	GameLoader.load_currency("coins")
	GameLoader.load_currency("diamonds")
	Loading.load_next(null, null, null)
	await Loading.screen_loaded
	emit_signal("login_checked")
	hide()
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_LOGIN, Analytics.login_params)
