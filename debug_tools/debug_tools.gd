extends CanvasLayer


func start() -> void:
	Globals.debug_tools = true
	$Timer.start()


func _ready() -> void:
	if Globals.debug_tools:
		$Timer.start()


func _on_Timer_timeout() -> void:
	if Globals.debug_tools:
		$Control.visible = Globals.debug_tools
		
