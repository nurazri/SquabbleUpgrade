class_name Board
extends Node2D

signal points_updated
signal letters_snatched
signal booster_used

@export var _BoardRed: Texture2D
@export var _StylePanelRed: StyleBox

@export (preload("res://globals.gd").LetterOwnership) var who_am_i

var _type: int = Globals.GameType.STANDARD

var _picked_letters: Array = []
var _longest_word: String = ""
var _best_word: String = ""
var _spelled_word: String = ""
var _most_points_from_word: int = 0

var _snatch_letters_count: int = 0
var _letters_tweened_count: int = 0

var _score: int = 0
var _score_next: int = 0
var _score_target: int = 0

var _can_interact: bool = true
var has_stolen: bool = false

var _boost_protection: bool = false
var _boost_protection_current: int = 0
var _current_boost_timer_queue: int = 0

var _is_touch_held_elsewhere: bool = false
var _is_touch_held: bool = false
var _can_snatch: bool = false
var _can_reset: bool = false
var _initial_touch_position = Vector2()
var _current_touch_position = Vector2()


#func _ready():
#	protect_board(20)


func _process(_delta) -> void:
	if _is_touch_held_elsewhere:
		end_touch()
	elif _is_touch_held and who_am_i == Globals.LetterOwnership.BOARD_ME and !_is_touch_held_elsewhere:
		if _current_touch_position.y > _initial_touch_position.y + 75 && $UI/Snatch.current == "snatch":
			snatch_and_clear()
			end_touch()
		elif _current_touch_position.y < _initial_touch_position.y - 150:
			reset_snatch()
			end_touch()
	else:
		return


func _input(event) -> void:
	if who_am_i == Globals.LetterOwnership.BOARD_ME && _can_snatch:
		if event is InputEventMouseButton:
			if event.pressed:
				start_touch(event.position)
			elif !event.pressed:
				end_touch()
		elif event is InputEventMouseMotion && _is_touch_held:
			start_touch(event.position)
		else:
			return


func start_touch(curr_position) -> void:
	var this_position = curr_position
	_current_touch_position = curr_position
	if _is_touch_held == false:
		_initial_touch_position = curr_position
		_is_touch_held = true


func end_touch() -> void:
	_is_touch_held = false


func reset(mode: int, type: int, scorelimit: int, continue_from_tutorial: bool = false) -> void:
	_type = type
	_picked_letters.clear()
	_snatch_letters_count = 0
	_letters_tweened_count = 0
	if not continue_from_tutorial:
		_score = 0
		_score_next = 0
	_spelled_word = ""
	_longest_word = ""
	_best_word = ""
	_most_points_from_word = 0
	
	_boost_protection_current = 0
	if _boost_protection:
		_boost_protection = false
	if has_stolen:
		has_stolen = false
	
	$UI/Snatch.hide()
	$Avatar.hide()
	
	if not mode == Globals.GameMode.TUTORIAL:
		$UI/Score.text = "0" + str(scorelimit)
		_score_target = scorelimit
		show_score_panel(true)
	
	set_interactivity(true)
	$BoardGrid.reset(who_am_i)
	
	if who_am_i == Globals.LetterOwnership.BOARD_ME:
		$Background/EffectLayer.hide()
		$HoldingBar.clear_letter()
		reset_booster()
	if who_am_i == Globals.LetterOwnership.BOARD_OPPONENT:
		$Background/TxtrctBoard.texture = _BoardRed
		$UI/ScorePanel.set("theme_override_styles/panel", _StylePanelRed)
		$UI/OpponentName.hide()
		
		$UI/Snatch.visible = false


func set_interactivity(can_interact: bool, timer: float = 0.0) -> void:
	print("Halt Interaction")
	_can_interact = can_interact
	if timer != 0.0:
		$Tween.interpolate_property($Background/Freeze_Effect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.15, Tween.TRANS_LINEAR)
		$Tween.start()
		await get_tree().create_timer(timer).timeout
		$Tween.interpolate_property($Background/Freeze_Effect, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR)
		$Tween.start()
		_can_interact = true
		print("Can Interact now")


func protect_board(timer: float = 0.0, booster_texture: Texture2D = null) -> void:
	$Background/EffectLayer.show()
	_boost_protection_current += randf_range(1,100)
	_current_boost_timer_queue = _boost_protection_current
	$Background/EffectLayer/Timer_Progress.value = 100
	$Background/EffectLayer/Protect_Booster.size = Vector2(0, 775)
	$Background/EffectLayer/Protect_Booster.position = Vector2(476,19)
	$Background/EffectLayer/Protect_Booster.modulate = Color(1,1,1,1)
	$Background/EffectLayer/Protect_Booster.texture = booster_texture
	
	$Tween.interpolate_property($Background/EffectLayer/Protect_Effect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.75, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Timer_Progress, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Timer_Progress, "value", 100, 0, timer, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "modulate", Color(1,1,1,1), Color(7,7,7,1), 0.45, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "modulate", Color(7,7,7,1), Color(0.5,0.8,10,0.45), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.45)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "size", Vector2(0,775), Vector2(765,775), 0.45, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "size", Vector2(765,775), Vector2(535,775), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.45)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "position", Vector2(476,19), Vector2(94,19), 0.45, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "position", Vector2(94,19), Vector2(209,19), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.45)
	$Tween.start()
	_boost_protection = true
	for id in WordList.get_spawned_letters_owned_by(Globals.LetterOwnership.BOARD_ME):
		WordList.spawned_letters[id]._boost_protected = true
	
	await get_tree().create_timer(timer).timeout
	$Tween.interpolate_property($Background/EffectLayer/Protect_Effect, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Timer_Progress, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($Background/EffectLayer/Protect_Booster, "modulate", Color(0.5,0.8,10,0.45), Color(0.5,0.8,10,0), 0.45, Tween.TRANS_LINEAR)
	$Tween.start()
	if _current_boost_timer_queue == _boost_protection_current:
		_boost_protection = false
		for id in WordList.get_spawned_letters_owned_by(Globals.LetterOwnership.BOARD_ME):
			WordList.spawned_letters[id]._boost_protected = false


func connect_spawned_letter(letter: Letter) -> void:
	letter.connect("letter_tweened", Callable(self, "_on_letter_tweened"))


func form_word_from_letters(letters: Array, all_letters_in_word_selected: bool) -> String:
	var text: String = ""
	for l in letters:
		if l and WordList.spawned_letters.has(l["id"]):
			text += WordList.spawned_letters[l["id"]]["letter"]
	return text


func clear_picked_letters(letters: Array = []) -> void:
	# Check if any letter in letters is also in _picked_letters
	var in_picked_letters: bool = false
	if not letters.is_empty():
		for letter in letters:
			for p in _picked_letters:
				if letter and p and letter.id == p.id:
					in_picked_letters = true
					break

	if letters.is_empty() or in_picked_letters:
		for letter in _picked_letters:
			if letter:
				letter.depress()
				letter.deselect()
		_picked_letters.clear()	
	elif not letters.is_empty() and not in_picked_letters:
		for letter in letters:
			for p in _picked_letters:
				if letter and p and letter.id == p.id:
					letter.depress()
					letter.deselect()
					var f: int = _picked_letters.find(p)
					if f >= 0:
						_picked_letters.remove(f)
	
	#_spelled_word = form_word_from_letters(_picked_letters, $BoardGrid.check_letters(_picked_letters))
	_spelled_word = ""
	#print(in_picked_letters)
	if who_am_i == Globals.LetterOwnership.BOARD_ME && in_picked_letters:
		$UI/Snatch.change_button("reset")
		$HoldingBar.reset_letter()
		$HoldingBar.clear_letter()


func pick_letter(id: int, is_picked: bool = true) -> void:
	var letter_node: Letter = WordList.spawned_letters[id]["node"]
	var word: String = ""
	if is_picked:
		_picked_letters.append(letter_node)
		if who_am_i == Globals.LetterOwnership.BOARD_ME:
			$HoldingBar.add_letter(letter_node)
	else:
		var found: int = _picked_letters.find(letter_node)
		if found > -1:
			_picked_letters.remove(found)
			if who_am_i == Globals.LetterOwnership.BOARD_ME:
				$HoldingBar.remove_letter(found)
	
	_spelled_word = form_word_from_letters(_picked_letters, $BoardGrid.check_letters(_picked_letters))
	var exist_pool_letter: bool = false
	var points_total: int = 0
	var owned_letters: int = 0
	for l in _picked_letters:
		if l and WordList.spawned_letters.has(l["id"]):
			word += WordList.spawned_letters[l["id"]]["letter"]
			if WordList.spawned_letters[l.id]["owned_by"] == Globals.LetterOwnership.POOL:
				exist_pool_letter = true
				points_total += WordList.spawned_letters[l["id"]]["points"]
			if WordList.spawned_letters[l.id]["owned_by"] == Globals.LetterOwnership.BOARD_OPPONENT:
				points_total += WordList.spawned_letters[l["id"]]["points"]
			if WordList.spawned_letters[l.id]["owned_by"] == Globals.LetterOwnership.BOARD_ME:
				owned_letters += 1
	
	if WordList.is_valid_word(word) && exist_pool_letter:
		var get_bonus_points: int = 0
		var get_current_bonus_points: int = 0
		if _picked_letters.size() >= 4:
			get_bonus_points = WordList._letters_bonus_points_metadata[str(_picked_letters.size())]["points_letter_bonus"]
		if owned_letters >= 4:
			get_current_bonus_points = WordList._letters_bonus_points_metadata[str(owned_letters)]["points_letter_bonus"]
		var subtotal: int = get_bonus_points - get_current_bonus_points
		points_total += subtotal
		
		$UI/Snatch.change_button("snatch", points_total)
		if who_am_i == Globals.LetterOwnership.BOARD_ME:
			$HoldingBar.highlight_snatch(word.length(), true)
	else:
		$UI/Snatch.change_button("reset")
		if who_am_i == Globals.LetterOwnership.BOARD_ME:
			$HoldingBar.highlight_snatch(word.length(), false)


func steal() -> Array:
	var steal_status: bool = false
	var letters_stolen: int = 0
	
	for i in _picked_letters:
		if WordList.spawned_letters[i.id]["owned_by"] == Globals.LetterOwnership.BOARD_OPPONENT && who_am_i == Globals.LetterOwnership.BOARD_ME:
			steal_status = true
			letters_stolen += 1
	
	return [steal_status, letters_stolen]


func snatch() -> bool:
	if WordList.is_valid_word(_spelled_word):
		_letters_tweened_count = 0
		_snatch_letters_count = _picked_letters.size()
		
		var sum: int = 0
		if _spelled_word.length() > _longest_word.length():
			_longest_word = _spelled_word
			for p in _picked_letters:
				sum += WordList.spawned_letters[p.id]["points"]
		elif _spelled_word.length() == _longest_word.length():
			for p in _picked_letters:
				sum += WordList.spawned_letters[p.id]["points"]
				
		if sum >= _most_points_from_word:
			_most_points_from_word = sum
			_best_word = _spelled_word
			
		#print(_picked_letters)
		if _boost_protection:
			for p in _picked_letters:
				WordList.spawned_letters[p.id]["node"]._boost_protected = true
				
		return $BoardGrid.add_letters(_picked_letters, who_am_i)
	return false


func snatch_and_clear(has_fail_sfx: bool = true, skip_sfx: bool = false) -> bool:
	if _can_interact:
		var picked: Array = _picked_letters.duplicate(true)
		var steal: Array = steal()
		var snatch: bool = snatch()
		
		if snatch:
			if !skip_sfx:
				Audio.play_sfx(Audio.Sfx.WORD_SUCCESS)
			emit_signal("letters_snatched", who_am_i, _spelled_word, _longest_word, _best_word, picked, steal)
			if !has_stolen:
				has_stolen = steal[0]
			
			$HoldingBar.clear_letter_alt()
			if who_am_i == Globals.LetterOwnership.BOARD_ME:
				$HoldingBar.highlight_snatch(0)
			$UI/Snatch.change_button("reset")
		
		clear_picked_letters(_picked_letters)
		return snatch
	else:
		return false


func reset_snatch() -> void:
	if _can_interact && _can_reset:
		Audio.play_sfx(Audio.Sfx.WORD_FAIL)
		clear_picked_letters(_picked_letters)
		pass


func reset_booster() -> void:
	for i in range(1,5):
		get_node("UI/Booster/Booster_Slot" + str(i)).reset_booster()


func set_avatar(avatar: Texture2D, background: Texture2D) -> void:
	$Avatar.set_avatar(avatar, background)


func show_info(can_show: bool = true) -> void:
	$UI/Score.text = "0"
	if _score_target != 0:
		$UI/Score.text = "0/" + str(_score_target)
		
	$Avatar.visible = can_show
	$UI/OpponentName.visible = can_show
	#$UI/Score.visible = can_show


func show_score_panel(can_show: bool = true) -> void:
	$UI/ScorePanel.visible = can_show
	$UI/Score.visible = can_show


func show_snatch_button(can_show: bool = true) -> void:
	$UI/Snatch.visible = false
	if who_am_i == Globals.LetterOwnership.BOARD_ME:
		if can_show:
			$UI/Snatch.show_button()


func enable_snatch_button(is_enabled: bool = true) -> void:
	$UI/Snatch.disabled = not is_enabled


func enable_snatch_swipe(is_enabled: bool = true) -> void:
	_can_snatch = is_enabled


func enable_reset(is_enabled: bool = true) -> void:
	_can_reset = is_enabled


func enable_boosters(is_enabled: bool = true) -> void:
	for i in range(1,5):
		if get_node("UI/Booster/Booster_Slot" + str(i))._booster_init:
			get_node("UI/Booster/Booster_Slot" + str(i)).visible = is_enabled


func set_name(name: String) -> void:
	$UI/OpponentName.text = name


func _on_Snatch_pressed() -> void:
	if $UI/Snatch.current == "snatch":
		snatch_and_clear()
		print("[Board] you pressed the snatch button!")


func _on_Booster_Slot_booster_used(booster: int, level: int) -> void:
	emit_signal("booster_used", booster, level)


func _on_letter_picked(id: int, is_picked: bool) -> void:
	_spelled_word = ""
	pick_letter(id, is_picked)


func _on_letter_tweened() -> void:
	_letters_tweened_count += 1
	if _letters_tweened_count >= _snatch_letters_count:
		get_tree().call_group("boardgrids", "update_points")


func _on_BoardGrid_points_updated(points: int, insert_point: Vector2):
	_score_next = points
	emit_signal("points_updated", points, who_am_i, insert_point)
	$PointsUpdateTimer.stop()
	$PointsUpdateTimer.start()


func _on_PointsUpdateTimer_timeout():
	if _score != _score_next:
		if _score < _score_next:
			_score += 1
		elif _score > _score_next:
			_score += -1
		
		if _score_target != 0:
			$UI/Score.text = str(_score) + "/" + str(_score_target)
		else:
			$UI/Score.text = str(_score)
		$PointsUpdateTimer.start()


func _on_Reset_pressed():
	reset_snatch()
	end_touch()
