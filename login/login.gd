extends Control

signal login_checked(is_login_checked)

func _ready() -> void:
	show()
	GameLoader.current_slot = 1
	
	var _game_data: Dictionary = GameLoader._load_game()
	var coins: int = GameLoader.load_currency("coins")
	var diamonds: int = GameLoader.load_currency("diamonds")
	
	await get_tree().create_timer(0.01).timeout
	
	if _game_data.is_empty():
		create_profile(1)
	else:
		select_profile(1)


func create_profile(slot: int, is_expert: bool = false) -> void:
	GameLoader.current_slot = slot
	GameLoader.save_game()
	GameLoader.save_achievement()
	GameLoader.save_currency("coins", 0)
	GameLoader.save_currency("diamonds", 0)
	GameLoader.check_keys_parity()
	select_profile(slot)


func select_profile(slot: int) -> void:
	GameLoader.current_slot = slot
	GameLoader.load_game()
	GameLoader.check_keys_parity()
	GameLoader.load_achievement()
	GameLoader.check_achievement_parity()
	
	# Load currencies safely using public methods
	var coins: int = GameLoader.load_currency("coins")
	var diamonds: int = GameLoader.load_currency("diamonds")
	
	# Correct usage: Node, Callable, Node
	Loading.load_next(
		self,                                 # arg1: Node
		Callable(self, "_on_load_next_done"), # arg2: Callable
		self                                  # arg3: Node
	)
	
	await Loading.screen_loaded
	
	emit_signal("login_checked", true)
	hide()
	
	Analytics.log_event(
		Globals.Analytics.ALL,
		Analytics.EVENT_LOGIN,
		Analytics.login_params
	)


# Success callback
func _on_load_next_done() -> void:
	pass
