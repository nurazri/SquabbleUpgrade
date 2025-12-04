extends Control

signal screen_loaded

@onready var _Default: Node2D = $Default
@onready var _LoadingBar: TextureProgressBar = $Default/LoadingBar

@onready var _Tween: Tween = $Tween


func _reset() -> void:	
	get_parent().call_deferred("move_child", self, get_parent().get_child_count() - 1)
	_LoadingBar.value = 0
	# warning-ignore:return_value_discarded
	_Tween.remove_all()


func _load_done() -> void:	
	get_parent().call_deferred("move_child", self, 0)
	emit_signal("screen_loaded")


func load_next(scene: Node, fRef: FuncRef, where: Node = get_tree().root, duration: float = 0.5, deferred: bool = false) -> void:
	_reset()
	_Default.show()

	# warning-ignore:return_value_discarded
	_Tween.interpolate_property(_LoadingBar, "value", _LoadingBar.value, 100, duration, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)	
	# warning-ignore:return_value_discarded
	_Tween.start()

	if scene:
		if deferred:
			where.call_deferred("add_child", scene)
		else:
			where.add_child(scene)
			
	if scene:
		scene.hide()
				
	await _Tween.tween_all_completed
	
	if fRef:
		fRef.call_func()
			
	if scene:
		scene.show()
	
	_load_done()
