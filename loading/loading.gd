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
	get_parent().call_deferred("move_child", self, 0)
	emit_signal("screen_loaded")
	
#func load_next(scene: Node, fRef: Callable, where: Node = get_tree().root, duration: float = 0.5, deferred: bool = false) -> void:
	#_reset()
	#_Default.show()
#
	#var tween = create_tween()
	#tween.tween_property(_LoadingBar, "value", 100, duration).from(_LoadingBar.value).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
#
	#if scene:
		#if deferred:
			#where.call_deferred("add_child", scene)
		#else:
			#where.add_child(scene)
				#
		#print("Loaded scene: ", scene.name)
		#scene.hide()
#
	#await tween.finished
#
	#if fRef:
		#fRef.call_func()
#
	#if scene:
		#scene.show()
	#
	#_load_done()

func load_next(scene: Node, fRef = null, where: Node = get_tree().root, duration: float = 0.5, deferred: bool = false) -> void:
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
		
		print("Loaded scene: ", scene.name)  # prints the scene's name
		print("Root class: ", scene.get_class())  # prints "Node", "Node2D", etc.
		
		print("Scene file: ", scene.scene_file_path)
		if scene.has_method("hide"):
			scene.hide()
		elif "visible" in scene:
			scene.visible = false # Hide initially
		else:
			print("scene didnt get hidden"); #adhwa rasanya loading screen x hilang sebb kita masuk sini

	# Call the function reference if provided
	if fRef:
		fRef.call()

	# Show the scene after loading
	if scene:
		if scene.has_method("show"):
			scene.show()
		elif "visible" in scene:
			scene.visible = true
		else:
			print("scene didnt get shown");
	
	_load_done()
