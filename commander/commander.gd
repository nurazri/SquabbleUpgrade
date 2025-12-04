extends Node2D

signal command_issued
signal spawn_command
signal ai_level_set


func command(command: Array) -> void:
	emit_signal("command_issued", command)


func start(_mode: int, _level: int) -> void:	
	$SpawnCommand.start_command(_mode)
	emit_signal("ai_level_set", _level)
	$AI.start_command(_level)
	# e.g.
	#	command(["s", "l" if randi() % 10 > 5 else "r", { "impulse": 700, "rotation_degrees": rand_range(0, 360) }, ["k"], 2.5])
	#	command(["m", Globals.LetterOwnership.ALL, Globals.LetterOwnership.BOARD_OPPONENT, [2, "e", "f", 3], 10])


func stop() -> void:
	$SpawnCommand.stop()
	$AI.set_process(false)
	$AI.stop()
	
	
func picker_command_succeeded(command: Array) -> void:
	$AI.picker_command_succeded(command)


func letters_snatched(from_who: int, longest_word: String, picked_letters: Array) -> void:
	$AI.letters_snatched(from_who, longest_word, picked_letters)


func _on_SpawnCommand_command_issued(command: Array) -> void:
	command(command)


func _on_AI_command_issued(command: Array) -> void:
	command(command)


func _on_SpawnCommand_spawn_command(is_issued: bool) -> void:
	emit_signal("spawn_command", is_issued)
