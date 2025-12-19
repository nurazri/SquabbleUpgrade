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
	if not disable_button:
		progress_button.disabled = true
		
	show()
	dialog_text.text = ""
	arrow_indicator.visible = false
	arrow_indicator.modulate = Color(1,1,1,0)
	next_indicator.visible = not disable_button
	progress_button.visible = not disable_button
	
	var char_index := 0
	while char_index < dialog.length():
		dialog_text.text = dialog.substr(0, char_index + 1)
		char_index += 1
		await get_tree().process_frame   # wait one frame per character
		# you can replace with `await get_tree().create_timer(0.02).timeout` for speed control
	
	arrow_indicator.visible = not disable_button
	arrow_indicator.modulate = Color(1,1,1,1)
	progress_button.disabled = false
