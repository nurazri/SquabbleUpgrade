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
#func interpret(command: Array) -> bool:
	#print("inside interpret inside picker.gd")
	#if command.size() < 3:
		#return false
	#
	#var check_where: int = command[1]
	#var move_to: int = command[2]
	#var letters: Array = []
#
	#if command.size() >= 5:
		#letters = command[3]
	#else:
		#return false
	#
	#var board: Board = _BoardMe if move_to == Globals.LetterOwnership.BOARD_ME else _BoardOpponent
	#if not board:
		#return false
	#
	#var picked_letters: Array = []
#
	#for letter in letters:
		#var letter_data: Dictionary = {}
		#
		#if typeof(letter) == TYPE_STRING:
			#var matching_letters: Array = []
			#var check_dictionary: Dictionary = WordList.get_spawned_letters_owned_by(check_where) if check_where != Globals.LetterOwnership.ALL else WordList.spawned_letters
			#for id in check_dictionary:
				#if WordList.spawned_letters[id]["letter"] == letter:
					#matching_letters.append(id)
			#if not matching_letters.is_empty():
				#letter_data = WordList.spawned_letters[matching_letters[randi() % matching_letters.size()]]
		#
		#elif typeof(letter) == TYPE_INT:
			#if WordList.spawned_letters.has(letter):
				#letter_data = WordList.spawned_letters[letter]
		#
		#if not letter_data.is_empty():  # Correct method for Godot 4 Dictionary
			#board.pick_letter(letter_data["id"])
			#picked_letters.append(letter_data["id"])
	#
	#if picked_letters.size() >= letters.size():
		#var picked_nodes: Array = []
		#for p in picked_letters:
			#if WordList.spawned_letters.has(p):
				#picked_nodes.append(WordList.spawned_letters[p]["node"])
		#
		#get_tree().call_group("boards", "clear_picked_letters", picked_nodes)
		#
		#if command.size() == 6:
			#return board.snatch_and_clear(false, command[5])
		#else:
			#return board.snatch_and_clear(false)
	#
	#board.clear_picked_letters()
	#return false
	
#func interpret(command: Array) -> bool:
	#print("inside interpret inside picker.gd, command is: ",command)
	#
	#if command.size() < 5:
		#print("command size less than 5")
		#return false
	#
	#var check_where: int = command[1]
	#var move_to: int = command[2]
	#
	## Extract letters correctly depending on command size
	#var letters: Array
	#if command.size() == 6:
		#print("command size is 6")
		#letters = command[command.size() - 3]  # index 3 when size 6
		#print("letters become: ",letters)
	#elif command.size() == 5:
		#print("command size is 5")
		#letters = command[command.size() - 2]  # index 3 when size 5
		#print("letters become: ",letters)
	#else:
		#print("command size is neither 5 or 6")
		#return false
	#
	#var board: Board = _BoardMe if move_to == Globals.LetterOwnership.BOARD_ME else _BoardOpponent
	#if not board:
		#print("not board")
		#return false
	#
	#var picked_letters: Array = []
	#
	#for letter in letters:
		#var letter_data: Dictionary = {}
		#
		#if typeof(letter) == TYPE_STRING:
			#var matching_letters: Array = []
			#var check_dictionary: Dictionary = (
				#WordList.get_spawned_letters_owned_by(check_where)
				#if check_where != Globals.LetterOwnership.ALL
				#else WordList.spawned_letters
			#)
			#
			#for id in check_dictionary:
				#if WordList.spawned_letters[id]["letter"] == letter:
					#matching_letters.append(id)
			#
			#if not matching_letters.is_empty():
				#var random_id = matching_letters[randi() % matching_letters.size()]
				#letter_data = WordList.spawned_letters[random_id]
		#
		#elif typeof(letter) == TYPE_INT:
			#if WordList.spawned_letters.has(letter):
				#letter_data = WordList.spawned_letters[letter]
		#
		#if not letter_data.is_empty():
			#board.pick_letter(letter_data["id"])
			#picked_letters.append(letter_data["id"])
			#
	#print("after for block")
	#print("picker_letters.size is: ",picked_letters.size())
	#print("letters.size is: ",letters.size())
	## Only proceed to clear/snatch if we picked all requested letters
	#if picked_letters.size() >= letters.size():
		#var picked_nodes: Array = []
		#for p in picked_letters:
			#if WordList.spawned_letters.has(p):
				#picked_nodes.append(WordList.spawned_letters[p]["node"])
		#
		#print("clear_picker_letters called 5")
		#get_tree().call_group("boards", "clear_picked_letters", picked_nodes)
		#
		#if command.size() == 6:
			#return board.snatch_and_clear(false, command[5])
		#else:
			#print("returning")
			#var boardSnatchValue = board.snatch_and_clear(false)
			#print("boardSnatchValue is: ", boardSnatchValue)
			#return boardSnatchValue
	#
	## If we didn't pick enough letters
	#print("clear_picker_letters called 6")
	#board.clear_picked_letters()
	#print("until the end of function")
	#return false
	
func interpret(command: Array) -> bool:
	
	var check_where: int = command[1]
	var move_to: int = command[2]
	var letters: Array
	if command.size() == 6:
		letters = command[command.size() - 3]
	elif command.size() == 5:
		letters = command[command.size() - 2]
	
	var board: Board = _BoardMe if move_to == Globals.LetterOwnership.BOARD_ME else _BoardOpponent
	
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
	
		if board and not letter_data.is_empty():
			board.pick_letter(letter_data["id"])
			picked_letters.append(letter_data["id"])
		
	if board and picked_letters.size() >= letters.size():
		var picked_nodes: Array = []
		for p in picked_letters:
			picked_nodes.append(WordList.spawned_letters[p]["node"])

		#get_tree().call_group("boards", "clear_picked_letters", picked_nodes)
		
		#print(WordList.get_spawned_letters_owned_by(check_where))
		if command.size() == 6:
			return board.snatch_and_clear(false, command[5])
		else:
			return board.snatch_and_clear(false)
	
	board.clear_picked_letters()
	return false
