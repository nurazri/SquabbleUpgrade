# If CommandInterpreter exists and is a global class, use:
# extends CommandInterpreter
# Otherwise, extend Node for now
extends CommandInterpreter

var _BoardMe: Board
var _BoardOpponent: Board

func reset() -> void:
	# Reset boards
	_BoardMe = null
	_BoardOpponent = null

func set_boards(board_me: Board, board_opponent: Board) -> void:
	_BoardMe = board_me
	_BoardOpponent = board_opponent

# Example command: ["m", Globals.LetterOwnership.ALL, Globals.LetterOwnership.BOARD_OPPONENT, [2, "e", "f", 3], 2.5]
func interpret(command: Array) -> bool:
	if command.size() < 3:
		return false
	
	var check_where: int = command[1]
	var move_to: int = command[2]
	var letters: Array = []

	if command.size() >= 5:
		letters = command[3]
	else:
		return false
	
	var board: Board = _BoardMe if move_to == Globals.LetterOwnership.BOARD_ME else _BoardOpponent
	if not board:
		return false
	
	var picked_letters: Array = []

	for letter in letters:
		var letter_data: Dictionary = {}
		
		if typeof(letter) == TYPE_STRING:
			var matching_letters: Array = []
			var check_dictionary: Dictionary = WordList.get_spawned_letters_owned_by(check_where) if check_where != Globals.LetterOwnership.ALL else WordList.spawned_letters
			for id in check_dictionary:
				if WordList.spawned_letters[id]["letter"] == letter:
					matching_letters.append(id)
			if not matching_letters.is_empty():
				letter_data = WordList.spawned_letters[matching_letters[randi() % matching_letters.size()]]
		
		elif typeof(letter) == TYPE_INT:
			if WordList.spawned_letters.has(letter):
				letter_data = WordList.spawned_letters[letter]
		
		if not letter_data.is_empty():  # Correct method for Godot 4 Dictionary
			board.pick_letter(letter_data["id"])
			picked_letters.append(letter_data["id"])
	
	if picked_letters.size() >= letters.size():
		var picked_nodes: Array = []
		for p in picked_letters:
			if WordList.spawned_letters.has(p):
				picked_nodes.append(WordList.spawned_letters[p]["node"])
		
		get_tree().call_group("boards", "clear_picked_letters", picked_nodes)
		
		if command.size() == 6:
			return board.snatch_and_clear(false, command[5])
		else:
			return board.snatch_and_clear(false)
	
	board.clear_picked_letters()
	return false
