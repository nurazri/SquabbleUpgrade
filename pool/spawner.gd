extends Node2D  # Change to Node or Node2D depending on your scene

signal letter_spawned

@export var _ScnLetter: PackedScene

var _spawned_letter_index: int = 0
var _enable_rotation: bool = false

func reset() -> void:
	_spawned_letter_index = 0


# Example command:
# command(["s", "l", { "impulse": 700, "rotation_degrees": rand_range(0, 360) }, ["a"], 2.5])
func interpret(current_command: Array) -> bool:
	if current_command.size() < 3:
		return false

	var pushed_from: String = current_command[1]
	var properties: Dictionary = current_command[2]

	# Extract letters array (assumes letters array is second-to-last or third-to-last)
	var letters: Array
	if current_command.size() != 6:
		letters = current_command[current_command.size() - 2]
	else:
		letters = current_command[current_command.size() - 3]

	for letter_char in letters:
		if WordList.decrease_letter_quantity(letter_char):
			var spawned_letter: Letter = _spawn(letter_char, WordList.get_letter_points(letter_char), pushed_from, properties, _enable_rotation)
			_push_in(spawned_letter, pushed_from, properties)

	return true


func _spawn(letter_char: String, points: int, pushed_from: String, properties: Dictionary = { "impulse": 500, "rotation_degrees": 0 }, enable_rotation: bool = false) -> Letter:
	var spawned_letter: Letter = _ScnLetter.instantiate() as Letter

	var direction: int = 1 if pushed_from == "r" else -1
	var distance_from_center: float = 50
	var spawned_x = (get_viewport_rect().size.x if pushed_from == "r" else 0) + distance_from_center * direction

	randomize()
	spawned_letter.global_position = Vector2(spawned_x, randf_range($TopLeft.global_position.y, $BottomRight.global_position.y))
	if enable_rotation:
		spawned_letter.rotation_degrees = properties.get("rotation_degrees", 0)
	if properties.has("disabled"):
		spawned_letter.disable(properties["disabled"])

	get_parent().add_child(spawned_letter)
	spawned_letter.init(_spawned_letter_index, letter_char, points, Globals.LetterOwnership.POOL)
	emit_signal("letter_spawned", spawned_letter)

	_spawned_letter_index += 1
	return spawned_letter


func _push_in(spawned_letter: Letter, pushed_from: String, properties: Dictionary = { "impulse": 500, "rotation_degrees": 0 }) -> void:
	var direction: int = -1 if pushed_from == "r" else 1
	var impulse: float = properties.get("impulse", 500)
	spawned_letter.apply_impulse(direction * Vector2.RIGHT * impulse, Vector2.ZERO)
