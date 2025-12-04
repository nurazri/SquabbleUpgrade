extends CanvasLayer

signal pool_started
signal name_changed

var _current: String = "intro"


func _ready():
	pass # Replace with function body.


func _input(event) -> void:	
	if event is InputEventScreenTouch or event is InputEventMouseButton or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):	
		match _current:
			"intro_2": $IntroUI/AnimTutorialUI.play("intro_3")
			"intro_3": $IntroUI/AnimTutorialUI.play("intro_4")
			"intro_4": $IntroUI/AnimTutorialUI.play("intro_5")
			"intro_7": $IntroUI/AnimTutorialUI.play("intro_8")


func _on_AnimTutorialUI_animation_finished(anim_name):
	match anim_name:
		"intro": $IntroUI/AnimTutorialUI.play("intro_2")
		"intro_2": _current = "intro_2"
		"intro_3": _current = "intro_3"
		"intro_4": _current = "intro_4"
		
		"intro_5":
			$IntroUI.hide()
			$IntroUI/AvatarBackground.hide()
			$IntroUI/AvatarBackgroundBorder.hide()
			GameLoader.player_data["tutorial_intro"] = 0
			GameLoader.save_game()
			get_tree().root.get_node("Game/Home_New").play_level(1, false, true)
			_current = "ended"
