extends Label


func _ready() -> void:
	visible = Globals.debug_tools


func _on_Timer_timeout() -> void:
	visible = Globals.debug_tools

