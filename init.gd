extends Control

@export var _ScnGame: PackedScene

var _debug_tools_toggle_button_press_count: int = 0

@onready var _ToggleConfirm: Window = $DebugToolsToggleConfirm


func _ready() -> void:
	# Initialize Adjust SDK if token exists
	if ProjectSettings.has_setting("LionStudios/AdjustAppToken"):
		var adjust_app_token: String = ProjectSettings.get_setting("LionStudios/AdjustAppToken")
		if Engine.has_singleton("GodotAdjust"):
			var adjust = Engine.get_singleton("GodotAdjust")
			adjust.init(adjust_app_token, not OS.is_debug_build())

	# Load Appodeal ads
	Appodeal.load_ad(Appodeal.AdType.INTERSTITIAL)
	await Appodeal.interstitial_loaded
	Appodeal.load_ad(Appodeal.AdType.REWARDED_VIDEO)
	await Appodeal.rewarded_ad_loaded


func _on_AnimateGameka_animation_finished(_anim_name: String) -> void:
	# Pass an empty Callable instead of null
	Loading.load_next(_ScnGame.instantiate(), Callable(), get_tree().root, 0.5, true)
	queue_free()


func _on_DebugToolsToggle_pressed() -> void:
	_debug_tools_toggle_button_press_count += 1
	if _debug_tools_toggle_button_press_count >= 3:
		# Show debug tools confirmation window
		_ToggleConfirm.popup()


func _on_DebugToolsToggleConfirm_about_to_show() -> void:
	get_tree().paused = true


func _on_DebugToolsToggleConfirm_popup_hide() -> void:
	get_tree().paused = false


func _on_Confirm_pressed() -> void:
	var text: String = $DebugToolsToggleConfirm/Password.text
	text = text.to_lower()
	if text == "arguel town party":
		DebugTools.start()
		_ToggleConfirm.hide()


func _on_Cancel_pressed() -> void:
	_ToggleConfirm.hide()


func _on_GooglePlayVersionChecker_visibility_changed() -> void:
	if $CanvasLayer/GooglePlayVersionChecker.visible:
		get_tree().paused = true
	else:
		get_tree().paused = false
