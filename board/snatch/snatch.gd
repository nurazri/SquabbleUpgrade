extends Button

var current: String = "reset"

func _ready() -> void:
	pass


func show_button() -> void:
	$AnimSnatch.stop(true)
	$AnimSnatch.play("show")


func change_button(this_button, points = 0) -> void:
	current = this_button
	match this_button:
		"reset":
			$Invalid.show()
			$Snatch.hide()
		"snatch": 
			$Invalid.hide()
			$Snatch.show()
			$Snatch/Points/Label.text= "+" + str(points)


func _on_BtnSnatch_pressed() -> void:
	match current:
		"reset": Audio.play_sfx(Audio.Sfx.WORD_FAIL)
		"snatch": Audio.play_sfx(Audio.Sfx.BUTTON_TAP)
