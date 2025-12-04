extends CommandInterpreter

var _BoardMe: Board
var _BoardOpponent: Board


func reset() -> void:
	init()


func set_boards(board_me: Board, board_opponent: Board):
	_BoardMe = board_me
	_BoardOpponent = board_opponent
	

# Example command: command(["m", Globals.LetterOwnership.ALL, Globals.LetterOwnership.BOARD_OPPONENT, [2, "e", "f", 3], 2.5])
func interpret(command: Array) -> bool:
	var check_where: int = command[1]
	var move_to: int = command[2]
	var letters: Array
	if command.size() == 6:
		letters = command[command.size() - 3]
	elif command.size() == 5:
		letters = command[command.size() - 2]
	
	var Board: Board = _BoardMe if move_to == Globals.LetterOwnership.BOARD_ME else _BoardOpponent
	
	var picked_letters: Array = []
	for letter in letters:		
		var letter_data: Dictionary = {}
		
		if typeof(letter) == TYPE_STRING:
			var matching_letters: Array = []
			var check_dictionary: Dictionary = WordList.get_spawned_letters_owned_by(check_where) if not check_where == Globals.LetterOwnership.ALL else WordList.spawned_letters
			for id in check_dictionary:
				if WordList.spawned_letters[id]["letter"] == letter:
					matching_letters.append(id)
			if not matching_letters.is_empty():
				letter_data = WordList.spawned_letters[matching_letters[randi() % matching_letters.size()]]
		
		if typeof(letter) == TYPE_INT:
			if WordList.spawned_letters.has(letter):
				letter_data = WordList.spawned_letters[letter]
	
		if Board and not letter_data.is_empty():
			Board.pick_letter(letter_data["id"])
			picked_letters.append(letter_data["id"])
		
	if Board and picked_letters.size() >= letters.size():
		var picked_nodes: Array = []
		for p in picked_letters:
			picked_nodes.append(WordList.spawned_letters[p]["node"])
		
		get_tree().call_group("boards", "clear_picked_letters", picked_nodes)
		
		#print(WordList.get_spawned_letters_owned_by(check_where))
		if command.size() == 6:
			return Board.snatch_and_clear(false, command[5])
		else:
			return Board.snatch_and_clear(false)
	
	Board.clear_picked_letters()
	return false
