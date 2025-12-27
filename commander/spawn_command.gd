extends Timer

signal command_issued
signal spawn_command

@export var MAX_LETTERS_SPAWNED: int = 15 # (int, 10, 40)
@export var EVERY_NTH_LETTER_A_VOWEL: int = 6
@export var letter_tile_impulse: float = 800

var _first_iteration: bool = false
var _mode: int = Globals.GameMode.NONE

var _nth_letter_spawned: int = 5


func start_command(mode: int) -> void:
	_mode = mode	
	_first_iteration = true
	_nth_letter_spawned = 0
	_spawn()
	

func _spawn_command() -> bool:
	randomize()
	
	var random_letter: String = WordList.get_random_letter()
	var vowels: Array = ["A", "E", "I", "O", "U"]
	if _first_iteration or _nth_letter_spawned % EVERY_NTH_LETTER_A_VOWEL == 0:
		for v in vowels:
			if not v in WordList.letters_keys:
				vowels.erase(v)
		if not vowels.is_empty():
			random_letter= vowels[randi() % vowels.size()]
	
	_nth_letter_spawned += 1
	_nth_letter_spawned %= 60
	
	if not WordList.letters_keys.is_empty():
		if _mode != Globals.GameMode.ENDLESS:
			emit_signal("command_issued", ["s", "l" if randf() < 0.5 else "r", { "impulse": letter_tile_impulse, "rotation_degrees": randf_range(0, 360) }, [random_letter.to_lower()], -1.0])
		else:
			emit_signal("command_issued", ["s", "l" if randf() < 0.5 else "r", { "impulse": letter_tile_impulse, "rotation_degrees": randf_range(0, 360) }, [random_letter.to_lower()], "stop_decrement",  -1.0])
		_first_iteration = false
		return true
		
	return false


func _spawn() -> void:
	if _first_iteration:
		emit_signal("spawn_command", _spawn_command())
	else:
		if WordList.get_spawned_letters_quantity_left() == 0:
			stop()
			await get_tree().create_timer(7).timeout
			if _mode == Globals.GameMode.TUTORIAL:
				var _level = get_tree().root.get_node("Game/Pool")._ai_level
				get_tree().root.get_node("Game/Pool/EventManager").retry = true
				get_tree().root.get_node("Game/Home_New").play_level(_level, false, false)
			return
		
		var pool: Dictionary = WordList.get_spawned_letters_owned_by(Globals.LetterOwnership.POOL)
		if  pool.size() < MAX_LETTERS_SPAWNED:
			emit_signal("spawn_command", _spawn_command())
		else:
			emit_signal("spawn_command", false)
			
		if pool.size() > MAX_LETTERS_SPAWNED - 2:
			for n in pool.size():
				if pool[pool.keys()[n]]["node"]._is_held == false:
					pool[pool.keys()[n]]["node"].expire()
					break
			#pool[pool.keys()[0]]["node"].expire()
	
	start()
