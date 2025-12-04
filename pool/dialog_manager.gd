extends Control

@onready var avatar1: TextureRect = $BigAvatar1
@onready var avatar2: TextureRect = $BigAvatar2

@onready var chara_name: Label = $Dialog/Name
@onready var dialog_text: RichTextLabel = $Dialog/DialogText
@onready var progress_button: Button = $Progress_Dialog
@onready var anim_player: AnimationPlayer = $DialogUI

func enable_dialog_text(is_visible) -> void:
	visible = is_visible
	progress_button.visible = is_visible


func start_dialog_text(dialog: String, expression: int, from_who: String, which_side: String, skip_intro: bool = true, init_delay: bool = false) -> void:
	if init_delay:
		await get_tree().create_timer(0.03).timeout
	
	show()
	progress_button.show()
	var current_avatar = null
	var shaded_avatar = null
	
	if skip_intro:
		anim_player.play("dynamic_text")
	match which_side:
		"left":
			avatar1.modulate = Color(1, 1, 1, 1)
			avatar2.modulate = Color(0.4, 0.4, 0.4, 1)
			current_avatar = avatar1
			shaded_avatar = avatar2
		"right":
			avatar2.modulate = Color(1, 1, 1, 1)
			avatar1.modulate = Color(0.4, 0.4, 0.4, 1)
			current_avatar = avatar2
			shaded_avatar = avatar1
		"none":
			avatar1.modulate = Color(0.4, 0.4, 0.4, 1)
			avatar2.modulate = Color(0.4, 0.4, 0.4, 1)
	
	match from_who:
		"Squab": current_avatar.texture = load("res://avatar/expression/Squab" + str(expression) + ".png")
		"Quabble": current_avatar.texture = load("res://avatar/expression/Quabble" + str(expression) + ".png")
		"Wallice": current_avatar.texture = load("res://avatar/expression/Wallice" + str(expression) + ".png")
		"Killa": current_avatar.texture = load("res://avatar/expression/Killa" + str(expression) + ".png")
		"Quarrel": current_avatar.texture = load("res://avatar/expression/Quarrel" + str(expression) + ".png")
		"Moniac": current_avatar.texture = load("res://avatar/expression/Moniac" + str(expression) + ".png")
		"Liona": current_avatar.texture = load("res://avatar/expression/Liona" + str(expression) + ".png")
		
	
	chara_name.text = from_who
	dialog_text.text = dialog
	progress_button.disabled = true
	
	await anim_player.animation_finished
	progress_button.disabled = false


func setup_dialog(has_left_avatar, has_right_avatar, focus, set_avatar1, set_avatar2) -> void:
	chara_name.text = ""
	dialog_text.text = ""
	
	anim_player.play("new_entrance_1")
	anim_player.seek(1.5, false)
	
	$BigAvatar1.position = Vector2(-125, 880)
	$BigAvatar2.position = Vector2(505, 880)
	avatar1.show() if has_left_avatar else avatar1.hide()
	avatar2.show() if has_right_avatar else avatar2.hide()
	match focus:
		"left":
			avatar1.modulate = Color(1, 1, 1, 1)
			avatar2.modulate = Color(0.4, 0.4, 0.4, 1)
		"right":
			avatar2.modulate = Color(1, 1, 1, 1)
			avatar1.modulate = Color(0.4, 0.4, 0.4, 1)
	
	if set_avatar1 != null:
		avatar1.texture = load(set_avatar1)
	if set_avatar2 != null:
		avatar2.texture = load(set_avatar2)
	enable_dialog_text(true)


func reset_dialog() -> void:
	avatar1.position = Vector2(-1240, 880)
	avatar2.position = Vector2(1240, 880)
	anim_player.play("new_entrance_1")
	anim_player.stop()
