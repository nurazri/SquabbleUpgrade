extends Control

var spacing: int = 111
var _letters_array: Array = []

func add_letter(this_letter) -> void:
	_letters_array.append(this_letter)
	rearrange_letter(false)


func remove_letter(this_letter_index: int) -> void:
	var direction = [-1, 1] 
	var get_direction = direction[randi() % direction.size()]
	
	print(_letters_array.size())
	await get_tree().create_timer(0.05).timeout
	
	var get_letter = WordList.spawned_letters[_letters_array[this_letter_index].id]
	
	if get_letter.owned_by == Globals.LetterOwnership.POOL:
		_letters_array[this_letter_index].apply_impulse(get_direction * Vector2.RIGHT * 6000, Vector2.ZERO)
		_letters_array[this_letter_index].apply_impulse(Vector2.UP * 3000, Vector2.ZERO)
		_letters_array[this_letter_index].get_node("Col").disabled = false
		_letters_array[this_letter_index]._in_holding_bar = false
	else:
		_letters_array[this_letter_index].move_to(
			Vector2(get_letter.global_position_x, get_letter.global_position_y), 
			0, 
			get_letter.owned_by, 
			get_letter.cell_index, 
			true, true, false
		)
		_letters_array[this_letter_index].get_node("Tap").button_pressed = false
	
	_letters_array.remove_at(this_letter_index)
	rearrange_letter()


func clear_letter_alt() -> void:
	_letters_array.clear()


func clear_letter() -> void:
	_letters_array.clear()
	highlight_snatch(0)


func reset_letter() -> void:
	for l in _letters_array:
		var direction = [-1,1] 
		var get_direction = direction[randi() % direction.size()]
		var get_letter = WordList.spawned_letters[l.id]
		
		if get_letter.owned_by == Globals.LetterOwnership.POOL:
			l.apply_impulse(get_direction * Vector2.RIGHT * 6000, Vector2.ZERO)
			l.apply_impulse(Vector2.UP * 3000, Vector2.ZERO)
			l.get_node("Col").disabled = false
		else:
			if l._initial_global_position_x != get_letter["global_position_x"] and l._initial_global_position_y != get_letter["global_position_y"]:
				l.move_to(Vector2(get_letter["global_position_x"], get_letter["global_position_y"]), 0, get_letter.owned_by, get_letter.cell_index, true, true, false)
			if get_letter.owned_by == Globals.LetterOwnership.BOARD_OPPONENT:
				l.deselect()
			l.get_node("Tap").button_pressed = false


func rearrange_letter(interrupt_flow: bool = true) -> void:
	var current: int = 0
	for l in _letters_array:
		var get_letter = WordList.spawned_letters[l.id]
		
		if interrupt_flow:
			l.move_to(Vector2(100 + (spacing * current), 1225), 0, get_letter.owned_by, get_letter.cell_index, true, true, true)
		else:
			if not l._is_moving:
				l.move_to(Vector2(100 + (spacing * current), 1225), 0, get_letter.owned_by, get_letter.cell_index, true, true, true)
		
		current += 1


func highlight_snatch(current_tiles: int, can_snatch: bool = false) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)

	for i in range(1, current_tiles + 1):
		var highlight := get_node("HBoxContainer/Word_Validation_" + str(i)) as Control

		var style := highlight.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			style = style.duplicate()
			style.bg_color = Color(0.14, 1, 0, 1) if can_snatch else Color(1, 0, 0, 1)
			highlight.add_theme_stylebox_override("panel", style)

		tween.tween_property(highlight, "modulate:a", 1.0, 0.2)

	for i in range(current_tiles + 1, 8):
		var highlight := get_node("HBoxContainer/Word_Validation_" + str(i)) as Control
		tween.tween_property(highlight, "modulate:a", 0.0, 0.2)
