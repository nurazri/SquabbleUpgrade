extends Control

@onready var anim_player: AnimationPlayer = $StaticDialogUI

@onready var arrow_indicator: TextureRect = $Panel/Arrow
@onready var next_indicator: RichTextLabel = $Panel/Next
@onready var dialog_text: RichTextLabel = $Panel/DialogText
@onready var progress_button: Button = $Progress_Dialog


func enable_static_text(is_visible) -> void:
	visible = is_visible
	progress_button.visible = is_visible


func start_static_text(dialog: String, disable_button: bool = false) -> void:
	if !disable_button:
		progress_button.disabled = true
		
	show()
	dialog_text.percent_visible = 0
	next_indicator.percent_visible = 0
	dialog_text.text = dialog
	
	arrow_indicator.visible = false
	arrow_indicator.modulate = Color(1,1,1,0)
	next_indicator.visible = !disable_button
	progress_button.visible = !disable_button
	anim_player.play("static_text")
	await anim_player.animation_finished
	arrow_indicator.visible = !disable_button
	arrow_indicator.modulate = Color(1,1,1,1)
	progress_button.disabled = false
