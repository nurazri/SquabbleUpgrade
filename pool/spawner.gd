extends CommandInterpreter

signal letter_spawned

@export var _ScnLetter: PackedScene

var _spawned_letter_index: int = 0
var _enable_rotation: bool = false

func reset() -> void:
	init()
	_spawned_letter_index = 0


# Example command: command(["s", "l", { "impulse": 700, "rotation_degrees": rand_range(0, 360) }, ["a"], 2.5])
func interpret(current_command: Array) -> bool:
	var pushed_from: String = current_command[1]
	var properties: Dictionary = current_command[2]
	
	if current_command.size() != 6:
		var letters: Array = current_command[current_command.size() - 2]
		for letter in letters:
			if WordList.decrease_letter_quantity(letter):
				var spawned_letter: RigidBody2D = _spawn(letter, WordList.get_letter_points(letter), pushed_from, properties, _enable_rotation)
				_push_in(spawned_letter, pushed_from, properties)
	else:
		var letters: Array = current_command[current_command.size() - 3]
		for letter in letters:
			var spawned_letter: RigidBody2D = _spawn(letter, WordList.get_letter_points(letter), pushed_from, properties, _enable_rotation)
			_push_in(spawned_letter, pushed_from, properties)
	
	return true


func _spawn(letter: String, points: int, pushed_from: String, properties: Dictionary = { "impulse": 500, "rotation_degrees": 0 }, enable_rotation: bool = false) -> Letter:
	var Letter: Letter = _ScnLetter.instantiate()
	
	var direction: int = 1 if pushed_from == "r" else -1
	var distance_from_center: float = 50
	# warning-ignore:incompatible_ternary
	var spawned_x = (get_viewport_rect().size.x if pushed_from == "r" else 0) + distance_from_center * direction
		
	randomize()
	Letter.global_position = Vector2(spawned_x, randf_range($TopLeft.global_position.y, $BottomRight.global_position.y))
	if enable_rotation:
		Letter.rotation_degrees = properties["rotation_degrees"]
	if properties.has("disabled"):
		Letter.disable(properties["disabled"])
	get_parent().add_child(Letter)
	
	Letter.init(_spawned_letter_index, letter, points, Globals.LetterOwnership.POOL)
	emit_signal("letter_spawned", Letter)
	
	_spawned_letter_index += 1
	return Letter


func _push_in(spawned_letter: Letter, pushed_from: String, properties: Dictionary = { "impulse": 500, "rotation_degrees": 0 }) -> void:
	var direction: int = -1 if pushed_from == "r" else 1
	var impulse: float = properties["impulse"]
	spawned_letter.apply_impulse(direction * Vector2.RIGHT * impulse, Vector2.ZERO)
