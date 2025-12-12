extends Control

signal screen_loaded

@onready var _Default: Node2D = $Default
@onready var _LoadingBar: TextureProgressBar = $Default/LoadingBar

var _tween: Tween  # Tween resource created dynamically


func _ready() -> void:
	# Initialize the Tween resource
	_tween = create_tween()


func _reset() -> void:    
	# Move this screen to the top of the parent stack
	get_parent().call_deferred("move_child", self, get_parent().get_child_count() - 1)
	_LoadingBar.value = 0
	
	# Stop any previous tween
	if _tween:
		_tween.kill()


func _load_done() -> void:    
	# Move this screen back to the bottom of the parent stack
	get_parent().call_deferred("move_child", self, 0)
	emit_signal("screen_loaded")


func load_next(scene: Node, fRef: Callable, where: Node = get_tree().root, duration: float = 0.5, deferred: bool = false) -> void:
	_reset()
	_Default.show()

	# Create a new Tween for this animation
	_tween = create_tween()
	_tween.tween_property(_LoadingBar, "value", 100, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await _tween.finished  # Wait until tween finishes

	# Add scene to the tree
	if scene:
		if deferred:
			where.call_deferred("add_child", scene)
		else:
			where.add_child(scene)
		
		scene.hide()  # Hide initially

	# Call the function reference if provided
	if fRef:
		fRef.call()

	# Show the scene after loading
	if scene:
		scene.show()
	
	_load_done()
