extends Label


func _on_Countdown_visibility_changed():
	$Anim.play("countdown")


func _on_Anim_animation_finished(_anim_name):
	$Anim.stop(true)
	hide()
