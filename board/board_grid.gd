extends TileMapLayer

signal points_updated

const _NUMBER_OF_COLUMNS: int = 10

@export var _EmptyCellIndicatorTexture: Texture2D
@export var show_empty_cells: bool = false

var _cells: Dictionary = {}

var _last_known_insert: Vector2
var _current_insert_index: int = 0
var _who_am_i: int = Globals.LetterOwnership.POOL

var _points_total: int = 0


# ----------------------------------------------------
# PUBLIC
# ----------------------------------------------------
func reset(who_am_i: int) -> void:
	_who_am_i = who_am_i
	_reset_points()
	_reset_cells()
	_show_empty_cells()


# ----------------------------------------------------
# LETTER VALIDATION
# ----------------------------------------------------
func check_letters(letters: Array) -> bool:
	if letters.size() <= 1:
		return false

	for letter in letters:
		if letter == null:
			return false

		if WordList.spawned_letters.has(letter.id):
			var word: Array = WordList.spawned_letters[letter.id]["word"] as Array
			if not word.is_empty():
				if word.size() >= letters.size():
					return false

				var count: int = 0
				for w in word:
					for l in letters:
						if l and l.id == w:
							count += 1

				if count != word.size():
					return false

	return true


# ----------------------------------------------------
# REMOVE LETTERS
# ----------------------------------------------------
func remove_letters(amount: int, return_to_board: bool = false) -> void:
	var stored_cells: Array = []
	var current_word: Array = []
	var current_array: int = -1

	for c in _cells.keys():
		_cells[c]["empty"] = true

	for id in WordList.get_spawned_letters_owned_by(_who_am_i):
		var data: Dictionary = WordList.spawned_letters[id]
		var cell_index: int = data["cell_index"]

		if cell_index >= 0 and _cells.has(cell_index):
			var cell: Dictionary = _cells[cell_index] as Dictionary
			var word: Array = data["word"] as Array

			cell["empty"] = false
			cell["id"] = data["id"]
			cell["points"] = data["points"]
			cell["word"] = word

			if current_word.is_empty() or current_word != word:
				current_word = word
				current_array += 1
				stored_cells.append([cell])
			else:
				stored_cells[current_array].append(cell)

	var selected_removal: Array = []
	var removal_score: int = 0

	for group in stored_cells:
		if group.size() <= amount:
			var temp_score: int = 0
			for cell in group:
				temp_score += cell["points"] as int

			if selected_removal.is_empty() or temp_score > removal_score:
				removal_score = temp_score
				selected_removal = group

	if selected_removal.is_empty():
		return

	for cell in selected_removal:
		cell["empty"] = true
		var id: int = cell["id"] as int
		var data: Dictionary = WordList.get_spawned_letter_data(id)
		var node: RigidBody2D = data.node

		if not return_to_board:
			node.queue_free()
			WordList.remove_spawned_letter(id)
		else:
			data.owned_by = Globals.LetterOwnership.POOL
			data.cell_index = -1
			(data["word"] as Array).clear()

			var col: CollisionShape2D = node.get_node("Col")
			col.disabled = true

			node.linear_velocity = Vector2.ZERO
			node.apply_impulse(Vector2.DOWN * 40000)

			await get_tree().create_timer(0.25).timeout
			col.disabled = false

	update_points()


# ----------------------------------------------------
# ADD LETTERS
# ----------------------------------------------------
func add_letters(letters: Array, who_am_i: int) -> bool:
	if not check_letters(letters):
		return false

	_update_cells_empty(who_am_i)

	for letter in letters:
		for c in _cells.keys():
			var cell: Dictionary = _cells[c] as Dictionary
			if WordList.spawned_letters[letter.id]["owned_by"] == who_am_i:
				if WordList.spawned_letters[letter.id]["cell_index"] == c:
					cell["empty"] = true

	if not _next_insert_index(letters):
		for id in WordList.get_spawned_letters_owned_by(who_am_i):
			var data: Dictionary = WordList.spawned_letters[id]
			var cell_index: int = data["cell_index"]
			var new_index: int = cell_index - _NUMBER_OF_COLUMNS
			var letter_node: Letter = data["node"]

			var selected: bool = false
			for l in letters:
				if l.id == id:
					selected = true
					break

			if cell_index < _NUMBER_OF_COLUMNS:
				if not selected:
					WordList.remove_spawned_letter(id)
					letter_node.queue_free()
			else:
				_move_letter(letter_node, new_index, who_am_i)

			_update_cells_empty(who_am_i)

		_next_insert_index(letters)

	_insert_letters(letters)
	_show_empty_cells()
	return true


# ----------------------------------------------------
# POINTS
# ----------------------------------------------------
func update_points() -> void:
	_points_total = 0
	var checked_words: Array = []

	for id in WordList.get_spawned_letters_owned_by(_who_am_i):
		var data: Dictionary = WordList.spawned_letters[id]
		var word: Array = data["word"] as Array

		if checked_words.has(word):
			continue

		checked_words.append(word)

		var word_points: int = 0
		var bonus: int = _update_points_bonus(word)

		for lid in word:
			word_points += WordList.get_spawned_letter_data(lid)["points"] as int

		_points_total += word_points + bonus

	emit_signal("points_updated", _points_total, _last_known_insert)


# ----------------------------------------------------
# GRID HELPERS
# ----------------------------------------------------
func _tile_size() -> Vector2:
	if tile_set:
		return tile_set.tile_size
	return Vector2(64, 64)

#func _grid_to_world(cell_position: Vector2) -> Vector2:
	#return map_to_local(cell_position) + _tile_size() / 2
	
func _grid_to_world(cell_position: Vector2) -> Vector2:
	var tile_size := _tile_size()
	var local_pos := Vector2(
		cell_position.x * tile_size.x + tile_size.x / 2,
		cell_position.y * tile_size.y + tile_size.y / 2
	)
	return to_global(local_pos)

func _show_empty_cells() -> void:
	if not show_empty_cells:
		return

	get_tree().call_group("iconpng", "queue_free")

	for i in _cells.keys():
		var cell: Dictionary = _cells[i] as Dictionary
		if cell["empty"] as bool:
			var s: Sprite2D = Sprite2D.new()
			s.texture = _EmptyCellIndicatorTexture
			s.global_position = _grid_to_world(cell["cell_position"] as Vector2)
			s.z_index = 400
			s.add_to_group("iconpng")
			get_parent().get_parent().add_child(s)

func _reset_cells() -> void:
	_cells.clear()
	var index: int = 0

	for row in range(4, -1, -1):
		for col in range(0, _NUMBER_OF_COLUMNS):
			_cells[index] = {
				"cell_position": Vector2(col, row),
				"cell_rotation": global_rotation_degrees,
				"empty": true,
				"id": 0,
				"points": 0,
				"word": []
			}
			index += 1


func _update_cells_empty(who_am_i: int = _who_am_i) -> void:
	for c in _cells.keys():
		var cell: Dictionary = _cells[c] as Dictionary
		cell["empty"] = true

	for id in WordList.get_spawned_letters_owned_by(who_am_i):
		var idx: int = WordList.spawned_letters[id]["cell_index"]
		if idx >= 0 and _cells.has(idx):
			var cell: Dictionary = _cells[idx] as Dictionary
			cell["empty"] = false


func _next_insert_index(letters: Array) -> bool:
	var length: int = letters.size()

	for c in _cells.keys():
		var end: int = c + length
		if end > _cells.size():
			continue

		var row: int = (_cells[c]["cell_position"] as Vector2).y
		var valid: bool = true

		for i in range(c, end):
			var cell_row: int = (_cells[i]["cell_position"] as Vector2).y
			if not (_cells[i]["empty"] as bool) or cell_row != row:
				valid = false
				break

		if valid:
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
	#var pos: Vector2 = _grid_to_world(_cells[target_index]["cell_position"] as Vector2)
	#var rot: float = _cells[target_index]["cell_rotation"] as float
	var pos: Vector2 = _grid_to_world(_cells[target_index]["cell_position"])
	var rot: float = _cells[target_index]["cell_rotation"]
	letter.move_to(pos, rot, who_am_i, target_index)


func _reset_points() -> void:
	_points_total = 0


func _update_points_bonus(letters: Array) -> int:
	var size: int = letters.size()
	if size >= 8:
		return WordList.letters_bonus_points_metadata["8"]["points_letter_bonus"] as int

	if WordList.letters_bonus_points_metadata.has(str(size)):
		return WordList.letters_bonus_points_metadata[str(size)]["points_letter_bonus"] as int

	return 0
