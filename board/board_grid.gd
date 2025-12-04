extends TileMap

signal points_updated

const _NUMBER_OF_COLUMNS: int = 10

@export var _EmptyCellIndicatorTexture: Texture2D
@export var show_empty_cells: bool = false

var _offset: Vector2: get = _get_offset
var _cells: Dictionary = {}

var _last_known_insert: Vector2
var _current_insert_index: int = 0
var _who_am_i: int = Globals.LetterOwnership.POOL

var _points_total: int = 0
#var _points_extra: int = 0


func reset(who_am_i: int) -> void:	
	_who_am_i = who_am_i
	_reset_points()
	_reset_cells()	
	_show_empty_cells()
#	print("BoardGrid global rotation_degrees: " + str(global_rotation_degrees))
#	for c in _cells:
#		print(_cells[c])


func check_letters(letters: Array) -> bool:
	if letters.size() <= 1:
		return false
	
	# Check if all letters in the same word are selected
	for letter in letters:
		if letter == null:
			return false
		if letter and WordList.spawned_letters.has(letter.id):
			if not WordList.spawned_letters[letter.id]["word"].is_empty():
				var selected_word: Array = WordList.spawned_letters[letter.id]["word"]
				if selected_word.size() >= letters.size():
					return false
				var count: int = 0
				for w in selected_word:
					for l in letters:
						if l and l.id == w:
							count += 1
				if not count == selected_word.size():
					return false
	return true


func remove_letters(amount: int, return_to_board: bool = false) -> void:
	var _stored_cells = []
	var _current_word = []
	var _current_array = -1
	
	for c in _cells:
		_cells[c]["empty"] = true
		for id in WordList.get_spawned_letters_owned_by(_who_am_i):
			if c == WordList.spawned_letters[id]["cell_index"]:
				_cells[c]["empty"] = false
				_cells[c]["id"] = WordList.spawned_letters[id]["id"]
				_cells[c]["points"] = WordList.spawned_letters[id]["points"]
				_cells[c]["word"] = WordList.spawned_letters[id]["word"]
				
				if _current_word.size() == 0 or _current_word != WordList.spawned_letters[id]["word"]:
					_current_word = WordList.spawned_letters[id]["word"]
					_current_array += 1
					_stored_cells.append([_cells[c]])
				else :
					_stored_cells[_current_array].append(_cells[c])
	
	#print(_stored_cells)
	var selected_removal = []
	var removal_score: int = 0
	
	for i in range(0, _stored_cells.size()):
		if _stored_cells[i].size() <= amount:
			var tempScore: int = 0
			if selected_removal.size() == 0 or selected_removal.size() <= _stored_cells[i].size():
				for score in _stored_cells[i]:
					tempScore += score["points"]
				if tempScore > removal_score:
					removal_score = tempScore
					selected_removal = _stored_cells[i]
	
	if not selected_removal.size() == 0:
		#print("Removal Score: " + str(removal_score))
		#print("Tiles to remove:" + str(selected_removal))
		for cells in selected_removal:
			cells["empty"] = true
			var explode_type: int = randf_range(1, 4)
			if !return_to_board:
				WordList.get_spawned_letter_data(cells["id"]).node._exit_tree()
				WordList.remove_spawned_letter(cells["id"])
			else:
				WordList.get_spawned_letter_data(cells["id"]).owned_by = Globals.LetterOwnership.POOL
				WordList.get_spawned_letter_data(cells["id"]).cell_index = -1
				WordList.get_spawned_letter_data(cells["id"]).word = []
				WordList.get_spawned_letter_data(cells["id"]).node.get_node("Col").disabled = true
				WordList.get_spawned_letter_data(cells["id"]).node.mode = RigidBody2D.MODE_CHARACTER
				WordList.get_spawned_letter_data(cells["id"]).node.apply_impulse(Vector2.DOWN * 40000, Vector2.ZERO)
				await get_tree().create_timer(0.25).timeout
				WordList.get_spawned_letter_data(cells["id"]).node.get_node("Col").disabled = false
				
	update_points()


func add_letters(letters: Array, who_am_i: int) -> bool:
	if not check_letters(letters):
		return false
	_update_cells_empty(who_am_i)

	for letter in letters:
		for c in _cells:
			if WordList.spawned_letters[letter.id]["owned_by"] == who_am_i:
				if WordList.spawned_letters[letter.id]["cell_index"] == c:
					_cells[c]["empty"] = true
	
	if not _next_insert_index(letters):
		for id in WordList.get_spawned_letters_owned_by(who_am_i):
			var letter_data: Dictionary = WordList.spawned_letters[id]
			var cell_index: int = letter_data["cell_index"]
			var new_index: int = cell_index - 10
			var letter: Letter = letter_data["node"]
			
			# Check if selected letter is in the bottom row
			var is_selected_in_last_row: bool = false
			for l in letters:
				if id == l.id:
					is_selected_in_last_row = true
					break

			if cell_index < _NUMBER_OF_COLUMNS:
				if not is_selected_in_last_row:
					#_points_extra += WordList.spawned_letters[id]["points"]
					# warning-ignore:return_value_discarded
					WordList.remove_spawned_letter(id)
					letter.queue_free()
			else:
				_move_letter(letter, new_index, who_am_i)
			_update_cells_empty(who_am_i)
			
		# warning-ignore:return_value_discarded
		_next_insert_index(letters)
	
	_insert_letters(letters)
	#_update_points_bonus(letters)
	_show_empty_cells()
	return true


func update_points() -> void:
	_points_total = 0
	var _checked_word: Array = []
	for l in WordList.get_spawned_letters_owned_by(_who_am_i):
		if !_checked_word.has(WordList.get_spawned_letter_data(l)["word"]):
			var _this_points = 0
			var _points_extra = _update_points_bonus(WordList.spawned_letters[l]["word"])
			var _return_multiplier = 0
			_checked_word.append(WordList.spawned_letters[l]["word"])
			for letters in WordList.spawned_letters[l]["word"]:
				_this_points += WordList.get_spawned_letter_data(letters)["points"]
				if WordList.get_spawned_letter_data(letters)["multiplier"] != 0:
					_return_multiplier += WordList.get_spawned_letter_data(letters)["multiplier"]
			
			_this_points += _points_extra
			if _return_multiplier > 0:
				_this_points * _return_multiplier
			_points_total += _this_points
		
	emit_signal("points_updated", _points_total, _last_known_insert)


func _get_offset() -> Vector2:
	return global_position + cell_size / 2
	
	
func _grid_to_world(cell_position: Vector2) -> Vector2:
	return map_to_local(cell_position) + self._offset

	
func _show_empty_cells() -> void:
	if show_empty_cells:
		get_tree().call_group("iconpng", "queue_free")	
		for i in _cells:
			if _cells[i]["empty"]:
				var s: Sprite2D = Sprite2D.new()
				s.texture = _EmptyCellIndicatorTexture
				s.global_position = _grid_to_world(_cells[i]["cell_position"])
				get_parent().get_parent().add_child(s)
				s.add_to_group("iconpng")
				s.z_index = 400


func _reset_cells() -> void:
	_cells.clear()
	var index: int = 0
	for row in range(4, -1, -1):
		for column in range(0, 10):
			_cells[index] = { "cell_position": Vector2(column, row), "cell_rotation": global_rotation_degrees, "empty": true, "id": 0, "points": 0, "word": [] }
			index += 1


func _get_empty_cells() -> Dictionary:
	var empty_cells: Dictionary = {}
	for c in _cells:
		if _cells[c]["empty"]:
			empty_cells[c] = _cells[c]
	return empty_cells


func _update_cells_empty(who_am_i: int = _who_am_i) -> void:
	var not_empty_indices: Array = []
	for c in _cells:
		_cells[c]["empty"] = true
		for id in WordList.get_spawned_letters_owned_by(who_am_i):
			if c == WordList.spawned_letters[id]["cell_index"]:
				not_empty_indices.append(c)	
	for ne in not_empty_indices:
		_cells[ne]["empty"] = false

	
func _next_insert_index(letters: Array) -> bool:
	var length: int = letters.size()
	for c in _cells:
		var is_first_column: bool = _cells[c]["cell_position"].x == 0
		
		var check_start_index: int = c if is_first_column else c - 1
		var check_end_index: int = c + length
		
		var empty: bool = true
		var same_row: bool = true
		
		if _cells[check_start_index]["empty"] and check_end_index < 50:
			for j in range(check_start_index, check_end_index):
				if j < 50:
					var check_index: int = j - 1 if _cells[j]["cell_position"].x == 9 else j + 1
					if not _cells[check_index]["empty"]:			
						empty = false
					if not _cells[check_index]["cell_position"].y == _cells[check_start_index]["cell_position"].y:
						same_row = false						
			if empty and same_row:
				_current_insert_index = c
				return true
	return false


func _insert_letters(letters: Array, who_am_i: int = _who_am_i, max_index: int = 50) -> void:
	var _get_middle_length: int = letters.size() / 2
	var _current_length: int = 0
	for letter in letters:
		_current_length += 1
		if _current_length == _get_middle_length:
			_last_known_insert = _grid_to_world(_cells[_current_insert_index]["cell_position"])
		
		WordList.spawned_letters[letter.id]["word"].clear() # clear all letters in the same word
		for l in letters:
			WordList.spawned_letters[letter.id]["word"].append(l.id) # assign all letters in the same word
		if _current_insert_index < max_index:
			var prev_cell_index: int = WordList.spawned_letters[letter.id]["cell_index"]
			if prev_cell_index < 0 or _cells[_current_insert_index]["empty"]:
				_move_letter(letter, _current_insert_index, who_am_i)
				_current_insert_index += 1


func _move_letter(letter: Letter, target_index: int, who_am_i: int = _who_am_i) -> void:
	var target_position: Vector2 = _grid_to_world(_cells[target_index]["cell_position"])
	var target_rotation: float = _cells[target_index]["cell_rotation"]
	letter.move_to(target_position, target_rotation, who_am_i, target_index)


func _reset_points() -> void:
	_points_total = 0
	#_points_extra = 0


func _update_points_bonus(letters: Array) -> int:
	if WordList.letters_bonus_points_metadata.has(str(letters.size())):
		match letters.size():
			4:
				return WordList.letters_bonus_points_metadata["4"]["points_letter_bonus"]
			5:
				return WordList.letters_bonus_points_metadata["5"]["points_letter_bonus"]
			6:
				return WordList.letters_bonus_points_metadata["6"]["points_letter_bonus"]
			7:
				return WordList.letters_bonus_points_metadata["7"]["points_letter_bonus"]
			8:
				return WordList.letters_bonus_points_metadata["8"]["points_letter_bonus"]
	elif letters.size() > 8:
		return WordList.letters_bonus_points_metadata["8"]["points_letter_bonus"]
	return 0
