class_name Board
extends Node2D

signal points_updated
signal letters_snatched
signal booster_used

@export var _BoardRed: Texture2D
@export var _StylePanelRed: StyleBox
@export var who_am_i: int = 0 # Use Globals.LetterOwnership

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
var _initial_touch_position: Vector2 = Vector2.ZERO
var _current_touch_position: Vector2 = Vector2.ZERO


# -------------------------
# Helper Functions
# -------------------------
func form_word_from_letters(letters: Array, all_letters_selected: bool) -> String:
	var text: String = ""
	for l in letters:
		if l and WordList.spawned_letters.has(l["id"]):
			text += WordList.spawned_letters[l["id"]]["letter"]
	return text


func steal() -> Array:
	var steal_status: bool = false
	var letters_stolen: int = 0
	
	for l in _picked_letters:
		if WordList.spawned_letters[l.id]["owned_by"] == Globals.LetterOwnership.BOARD_OPPONENT and who_am_i == Globals.LetterOwnership.BOARD_ME:
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
		
		if _boost_protection:
			for p in _picked_letters:
				WordList.spawned_letters[p.id]["node"]._boost_protected = true
		
		return $BoardGrid.add_letters(_picked_letters, who_am_i)
	
	return false


func clear_picked_letters(letters: Array = []) -> void:
	for letter in _picked_letters:
		if letter:
			letter.depress()
			letter.deselect()
	_picked_letters.clear()
	_spelled_word = ""
	if who_am_i == Globals.LetterOwnership.BOARD_ME:
		$UI/Snatch.change_button("reset")
		$HoldingBar.reset_letter()
		$HoldingBar.clear_letter()


func update_snatch_ui() -> void:
	if WordList.is_valid_word(_spelled_word):
		$UI/Snatch.change_button("snatch")
	else:
		$UI/Snatch.change_button("reset")


func reset_booster() -> void:
	for i in range(1,5):
		get_node("UI/Booster/Booster_Slot" + str(i)).reset_booster()


# -------------------------
# Touch Handling
# -------------------------
func start_touch(curr_position: Vector2) -> void:
	_current_touch_position = curr_position
	if not _is_touch_held:
		_initial_touch_position = curr_position
		_is_touch_held = true


func end_touch() -> void:
	_is_touch_held = false


# -------------------------
# Input & Process
# -------------------------
func _process(_delta: float) -> void:
	if _is_touch_held_elsewhere:
		end_touch()
	elif _is_touch_held and who_am_i == Globals.LetterOwnership.BOARD_ME and not _is_touch_held_elsewhere:
		if _current_touch_position.y > _initial_touch_position.y + 75 and $UI/Snatch.current == "snatch":
			snatch_and_clear()
			end_touch()
		elif _current_touch_position.y < _initial_touch_position.y - 150:
			reset_snatch()
			end_touch()


func _input(event: InputEvent) -> void:
	if who_am_i == Globals.LetterOwnership.BOARD_ME and _can_snatch:
		if event is InputEventMouseButton:
			if event.pressed:
				start_touch(event.position)
			else:
				end_touch()
		elif event is InputEventMouseMotion and _is_touch_held:
			start_touch(event.position)


# -------------------------
# Snatch & Reset
# -------------------------
func snatch_and_clear(has_fail_sfx: bool = true, skip_sfx: bool = false) -> bool:
	if not _can_interact:
		return false

	var picked: Array = _picked_letters.duplicate(true)
	var steal_info: Array = steal()
	var snatch_success: bool = snatch()
	
	if snatch_success:
		if not skip_sfx:
			Audio.play_sfx(Audio.Sfx.WORD_SUCCESS)
		emit_signal("letters_snatched", who_am_i, _spelled_word, _longest_word, _best_word, picked, steal_info)
		if not has_stolen:
			has_stolen = steal_info[0]
		
		$HoldingBar.clear_letter_alt()
		if who_am_i == Globals.LetterOwnership.BOARD_ME:
			$HoldingBar.highlight_snatch(0)
		$UI/Snatch.change_button("reset")
	
	reset_snatch()
	return snatch_success


func reset_snatch() -> void:
	if _can_interact and _can_reset:
		Audio.play_sfx(Audio.Sfx.WORD_FAIL)
		clear_picked_letters(_picked_letters)


# -------------------------
# Reset / Interactivity
# -------------------------
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
	_boost_protection = false
	has_stolen = false
	
	$UI/Snatch.hide()
	$Avatar.hide()
	
	if mode != Globals.GameMode.TUTORIAL:
		_score_target = scorelimit
		show_score_panel(true)
		$UI/Score.text = "0/" + str(scorelimit)
	
	set_interactivity(true)
	$BoardGrid.reset(who_am_i)
	
	if who_am_i == Globals.LetterOwnership.BOARD_ME:
		$Background/EffectLayer.hide()
		$HoldingBar.clear_letter()
		reset_booster()
	elif who_am_i == Globals.LetterOwnership.BOARD_OPPONENT:
		$Background/TxtrctBoard.texture = _BoardRed
		$UI/ScorePanel.set("theme_override_styles/panel", _StylePanelRed)
		$UI/OpponentName.hide()
		$UI/Snatch.visible = false


func set_interactivity(can_interact: bool, timer: float = 0.0) -> void:
	_can_interact = can_interact
	if timer > 0.0:
		$Tween.interpolate_property($Background/Freeze_Effect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.15, Tween.TRANS_LINEAR)
		$Tween.start()
		await get_tree().create_timer(timer).timeout
		$Tween.interpolate_property($Background/Freeze_Effect, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR)
		$Tween.start()
		_can_interact = true


# -------------------------
# UI Helpers
# -------------------------
func show_score_panel(can_show: bool = true) -> void:
	$UI/ScorePanel.visible = can_show
	$UI/Score.visible = can_show


func pick_letter(id: int, is_picked: bool = true) -> void:
	var letter_node: Letter = WordList.spawned_letters[id]["node"]
	if is_picked:
		_picked_letters.append(letter_node)
		if who_am_i == Globals.LetterOwnership.BOARD_ME:
			$HoldingBar.add_letter(letter_node)
	else:
		var idx: int = _picked_letters.find(letter_node)
		if idx >= 0:
			_picked_letters.remove_at(idx)  # ✅ Godot 4 fix
			if who_am_i == Globals.LetterOwnership.BOARD_ME:
				$HoldingBar.remove_letter(idx)
	
	_spelled_word = form_word_from_letters(_picked_letters, $BoardGrid.check_letters(_picked_letters))
	update_snatch_ui()
