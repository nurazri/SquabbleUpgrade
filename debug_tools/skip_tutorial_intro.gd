extends Button


func _ready() -> void:
	hide()


func _on_SkipTutorialIntro_pressed() -> void:
	var game: Node2D = get_tree().root.get_node("Game")
	if game:
		var pool: Node2D = game.get_node("Pool")
		var event_manager: Node2D = pool.get_node("EventManager")
		event_manager.manual_transition_result_screen()


func _on_Timer_timeout() -> void:
	var game: Node2D = get_tree().root.get_node("Game")
	if game:
		var pool: Node2D = game.get_node("Pool")
		if pool:
			var win_lose: Node2D = pool.get_node("UI/WinLose")
			visible = pool._mode == Globals.GameMode.TUTORIAL && not win_lose.visible 
			if not Globals.GameMode.TUTORIAL:
				visible = false

