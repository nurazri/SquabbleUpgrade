extends Button


func _ready() -> void:
	hide()


func _on_SkipIntro_pressed() -> void:
	var game: Node2D = get_tree().root.get_node("Game")
	if game:
		var tutorial: Node2D = game.get_node("Tutorial")
		if tutorial:
			tutorial.hide()
			var intro_ui: Control = tutorial.get_node("IntroLayer/IntroUI")
			if intro_ui:
				intro_ui.hide()


func _on_Timer_timeout() -> void:
	var game: Node2D = get_tree().root.get_node("Game")
	if game:
		var tutorial: Node2D = game.get_node("Tutorial")
		if tutorial:
			var intro_ui: Control = tutorial.get_node("IntroLayer/IntroUI")
			if intro_ui:
				visible = intro_ui.visible
