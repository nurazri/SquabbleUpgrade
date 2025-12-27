#class_name Letter
#extends RigidBody2D
#
## warning-ignore:unused_signal
#signal letter_autopicked
## warning-ignore:unused_signal
#signal letter_picked
#signal letter_tweened
#
#const _PUSH_IN_MARGIN: float = 100.0
#const _PUSH_IN_FORCE: float = 700.0
#
#var id: int = -1
#var letter: String = ""
#
#var _original_shake_position: Vector2 = Vector2.ZERO
#var _target_position: Vector2 = Vector2.ZERO
#var _prev_freeze_enabled: bool = false
#var _prev_freeze_mode: int = RigidBody2D.FREEZE_MODE_STATIC
#
#var _skip_interpolate: bool = false
#var _in_holding_bar: bool = false
#var _is_held: bool = false
#var _is_expiring: bool = false
#var _is_moving: bool = false
#
#var _forced_disable: bool = false
#
#var _is_touch_held: bool = false
#var _initial_touch_position: Vector2 = Vector2.ZERO
#var _current_touch_position: Vector2 = Vector2.ZERO
#var _initial_global_position_x: float = 0.0
#var _initial_global_position_y: float = 0.0
#
#var _boost_protected: bool = false
#
#var tween := create_tween()
#var tween_move
#var tween_move2
#
#
#func _process(delta: float) -> void:
	#if $Tap.disabled:
		#return
	#if _in_holding_bar and _is_touch_held:
		#if _current_touch_position.y < _initial_touch_position.y - 80:
			#$Tap.button_pressed = false
			#select($Tap.pressed, false)
			#end_touch()
#
#
#func _on_Letter_gui_input(event: InputEvent) -> void:
	#if _in_holding_bar:
		#if event is InputEventMouseButton:
			#if event.pressed:
				#start_touch(event.position)
			#elif not event.pressed:
				#end_touch()
		#elif event is InputEventMouseMotion and _is_touch_held:
			#start_touch(event.position)
#
#
#func start_touch(curr_position: Vector2) -> void:
	#_current_touch_position = curr_position
	#if not _is_touch_held:
		#_initial_touch_position = curr_position
		#_is_touch_held = true
		#get_tree().root.get_node("Game/Pool/BoardMe")._is_touch_held_elsewhere = true
#
#
#func end_touch() -> void:
	#_is_touch_held = false
	#get_tree().root.get_node("Game/Pool/BoardMe")._is_touch_held_elsewhere = false
#
#
#func init(id_: int, letter_: String, points: int, ownership: int) -> void:
	#id = id_
	#letter = letter_
	#$LetterSprite/Letter.text = letter_.to_upper()
	#$LetterSprite/Points.text = str(points)
	#_initial_global_position_x = global_position.x
	#_initial_global_position_y = global_position.y
	#WordList.add_spawned_letter({ 
		#"id": id_,
		#"letter": letter_,
		#"points": points,
		#"multiplier": 0,
		#"global_position_x": global_position.x,
		#"global_position_y": global_position.y,
		#"rotation_degrees": global_rotation_degrees,
		#"owned_by": ownership,
		#"cell_index": -1,
		#"node": self,
		#"word": []
	#})
#
#
#func update_letter_positional_data() -> void:
	#if _in_holding_bar:
		#return
	#
	#WordList.spawned_letters[id]["global_position_x"] = global_position.x
	#WordList.spawned_letters[id]["global_position_y"] = global_position.y
	#WordList.spawned_letters[id]["rotation_degrees"] = global_rotation_degrees
#
#
#func move_to(target_position: Vector2, target_rotation: float, moved_to_whom: int, cell_index: int, holding_bar_condition: bool = false, skip_interpolate: bool = false, in_holding_bar: bool = false) -> void:
	#if tween_move:
		#tween_move.kill()
		#tween_move = null
#
	#if tween_move2:
		#tween_move2.kill()
		#tween_move2 = null
#
	#
	#_in_holding_bar = in_holding_bar
	#_is_moving = true
	#$Tap.disabled = holding_bar_condition
	#get_parent().call_deferred("move_child", self, get_parent().get_child_count() - 1)
	#$PushInTimer.stop()
		#
	#if WordList.spawned_letters[id]["owned_by"] != moved_to_whom:
		#$AnimParticle.play("Scoring")
#
	## Save previous state
	#_prev_freeze_enabled = freeze
	#_prev_freeze_mode = freeze_mode
#
	## Freeze the letter like MODE_STATIC
	#freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	#set_freeze_enabled(true)
#
	#if !holding_bar_condition:
		#_prev_freeze_enabled = freeze
		#_prev_freeze_mode = freeze_mode
	#
	#$Col.disabled = true
	#
	#WordList.spawned_letters[id]["owned_by"] = moved_to_whom
	#WordList.spawned_letters[id]["cell_index"] = cell_index
	#if WordList.spawned_letters[id]["owned_by"] == Globals.LetterOwnership.BOARD_OPPONENT:
		#_is_expiring = false
	#
	#_target_position = target_position
	#
	#if not is_inside_tree():
		#await ready
#
	##var tween := get_tree().create_tween()
#
	#var pos_tween
	#if _skip_interpolate or skip_interpolate:
		#pos_tween = tween.tween_property(
			#self,
			#"global_position",
			#global_position,
			#0.2
		#)
	#else:
		#pos_tween = tween.tween_property(
			#self,
			#"global_position",
			#global_position - Vector2.DOWN * 150,
			#0.2
		#)
#
	#if pos_tween:
		#pos_tween.set_trans(Tween.TRANS_LINEAR)
		#pos_tween.set_ease(Tween.EASE_OUT)
#
	#var rot_tween = tween.tween_property(
		#self,
		#"global_rotation_degrees",
		#target_rotation,
		#1.0
	#)
#
	#if rot_tween:
		#rot_tween.set_trans(Tween.TRANS_BACK)
#
	#$Tap.disabled = true
#
#
#
#func select(is_picked: bool = true, is_auto: bool = true) -> void:
	## Freeze/unfreeze instead of changing mode
	#if is_picked:
		## Save previous state
		#_prev_freeze_enabled = freeze
		#_prev_freeze_mode = freeze_mode
		#
		#freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
		#set_freeze_enabled(true)
	#else:
		## Restore previous state
		#freeze_mode = _prev_freeze_mode
		#set_freeze_enabled(_prev_freeze_enabled)
#
	## Emit appropriate signal
	#emit_signal("letter_autopicked" if is_auto else "letter_picked", id, is_picked)
#
	## Animation and held state
	#if is_picked:
		#$AnimTap.play("tap")
		#_is_held = true
		#if _is_expiring:
			#_is_expiring = false
#
		## Move letter to top of parent
		#get_parent().call_deferred(
			#"move_child",
			#self,
			#get_parent().get_child_count() - 1
		#)
	#else:
		#$AnimTap.play_backwards("tap")
		#_is_held = false
#
#
#
#
#
#func deselect(is_auto: bool=true) -> void:
	#select(false, is_auto)
#
#
#func depress() -> void:
	#$Tap.button_pressed = false
	#
	#
#func disable(is_disabled: bool=true) -> void:
	#$Tap.disabled = is_disabled
#
#
#func force_disable(is_disabled: bool=true) -> void:
	#_forced_disable = is_disabled
#
#
#func expire() -> void:
	#if _is_expiring:
		#return
#
	#_is_expiring = true
	#for n in 3:
		#$TweenExpire.interpolate_property($LetterSprite, "rotation_degrees", $LetterSprite.rotation_degrees, 15, 2 - (0.5 * n), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		#$TweenExpire.interpolate_property($LetterSprite, "rotation_degrees", $LetterSprite.rotation_degrees + 15, -15, 4 - (1 * n), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 2 - (0.5 * n))
		#$TweenExpire.interpolate_property($LetterSprite, "rotation_degrees", $LetterSprite.rotation_degrees - 15, 0, 2 - (0.5 * n), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 6 - (1.5 * n))
		#$TweenExpire.start()
		#if not _is_expiring:
			#$TweenExpire.remove_all()
			#return
		#await $TweenExpire.tween_all_completed
	#for n in 6:
		#$TweenExpire.interpolate_property($LetterSprite, "rotation_degrees", $LetterSprite.rotation_degrees, 15, 0.3 - (0.05 * n), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		#$TweenExpire.interpolate_property($LetterSprite, "rotation_degrees", $LetterSprite.rotation_degrees + 15, -15, 0.6 - (0.1 * n), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3 - (0.05 * n))
		#$TweenExpire.interpolate_property($LetterSprite, "rotation_degrees", $LetterSprite.rotation_degrees - 15, 0, 0.3 - (0.05 * n), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.9 - (0.15 * n))
		#$TweenExpire.start()
		#if not _is_expiring and n < 3:
			#$TweenExpire.remove_all()
			#return
		#if n == 3:
			#deselect(false)
			#if id in WordList.get_spawned_letters_owned_by(Globals.LetterOwnership.POOL):
				#$Tap.disabled = true
				#WordList.remove_spawned_letter(id)
		#await $TweenExpire.tween_all_completed
	#
	#queue_free()
#
#
#func tween_win_lose_move(to: Vector2, duration: float, delay: float) -> void:
	#$TweenWinLoseMove.interpolate_property(self, "global_position", global_position, to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)	
	#$TweenWinLoseMove.start()
#
#
#func tween_win_lose_fade(duration: float, delay: float) -> void:
	#$TweenWinLoseFade.interpolate_property(self, "modulate", modulate, Color.WHITE, duration, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	#$TweenWinLoseFade.start()
#
#
#func _on_Tap_pressed() -> void:
	#var board = get_tree().root.get_node("Game/Pool/BoardMe")
	#
	## Check if the board already has 7 picked letters
	#if board._picked_letters.size() >= 7:
		#$Tap.release()  # Release the button properly
		#return
	#
	## Play the letter selection sound
	#Audio.play_sfx(Audio.Sfx.LETTER_SELECTED)
	#
	## Call select() on this letter
	## - is_picked: true because the button was pressed
	## - is_auto: false because this is a manual pick
	#select(true, false)
#
#
#
#
#func _on_PushInTimer_timeout() -> void:
	#if global_position.x < _PUSH_IN_MARGIN or global_position.x > get_viewport_rect().size.x - _PUSH_IN_MARGIN:
		#var direction = Vector2(get_viewport_rect().size.x / 2 - global_position.x, global_position.y).normalized()
		#apply_impulse(direction * Vector2.RIGHT * _PUSH_IN_FORCE, Vector2.ZERO)
#
#
#func _on_TweenMove_tween_completed(_object: Object, key: String) -> void:
	#if key == ":global_position":
		#$TweenMove2.interpolate_property(self, "global_position", global_position, _target_position, 1.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		#$TweenMove2.start()
#
#
#func _on_TweenMove2_tween_all_completed() -> void:
	#$LetterSprite.position = Vector2(-2, 8)
	#emit_signal("letter_tweened")
	#_is_moving = false
	#update_letter_positional_data()
	#if not _forced_disable:
		#$Tap.disabled = false
#
#
#func _on_TweenInvalid_tween_all_completed() -> void:
	#$TweenMove2.interpolate_property($LetterSprite, "position", $LetterSprite.position, _original_shake_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#$TweenMove2.start()
#
#
#func _exit_tree() -> void:
	#queue_free()

class_name Letter
extends RigidBody2D

# warning-ignore:unused_signal
signal letter_autopicked
# warning-ignore:unused_signal
signal letter_picked
signal letter_tweened

const _PUSH_IN_MARGIN: float = 100.0
const _PUSH_IN_FORCE: float = 700.0

var id: int = -1
var letter: String = ""

var _original_shake_position: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _prev_freeze_enabled: bool = false
var _prev_freeze_mode: int = RigidBody2D.FREEZE_MODE_STATIC

var _skip_interpolate: bool = false
var _in_holding_bar: bool = false
var _is_held: bool = false
var _is_expiring: bool = false
var _is_moving: bool = false

var _forced_disable: bool = false

var _is_touch_held: bool = false
var _initial_touch_position: Vector2 = Vector2.ZERO
var _current_touch_position: Vector2 = Vector2.ZERO
var _initial_global_position_x: float = 0.0
var _initial_global_position_y: float = 0.0

var _boost_protected: bool = false

var _move_tween: Tween

# No persistent tween variables needed anymore
# We create tweens on-demand in each function

func _process(delta: float) -> void:
	if $Tap.disabled:
		return
	if _in_holding_bar and _is_touch_held:
		if _current_touch_position.y < _initial_touch_position.y - 80:
			$Tap.button_pressed = false
			select($Tap.button_pressed, false)
			end_touch()


func _on_Letter_gui_input(event: InputEvent) -> void:
	if _in_holding_bar:
		if event is InputEventMouseButton:
			if event.pressed:
				start_touch(event.position)
			elif not event.pressed:
				end_touch()
		elif event is InputEventMouseMotion and _is_touch_held:
			start_touch(event.position)


func start_touch(curr_position: Vector2) -> void:
	_current_touch_position = curr_position
	if not _is_touch_held:
		_initial_touch_position = curr_position
		_is_touch_held = true
		get_tree().root.get_node("Game/Pool/BoardMe")._is_touch_held_elsewhere = true


func end_touch() -> void:
	_is_touch_held = false
	get_tree().root.get_node("Game/Pool/BoardMe")._is_touch_held_elsewhere = false


func init(id_: int, letter_: String, points: int, ownership: int) -> void:
	id = id_
	letter = letter_
	$LetterSprite/Letter.text = letter_.to_upper()
	$LetterSprite/Points.text = str(points)
	_initial_global_position_x = global_position.x
	_initial_global_position_y = global_position.y
	WordList.add_spawned_letter({ 
		"id": id_,
		"letter": letter_,
		"points": points,
		"multiplier": 0,
		"global_position_x": global_position.x,
		"global_position_y": global_position.y,
		"rotation_degrees": global_rotation_degrees,
		"owned_by": ownership,
		"cell_index": -1,
		"node": self,
		"word": []
	})


func update_letter_positional_data() -> void:
	if _in_holding_bar:
		return
	
	WordList.spawned_letters[id]["global_position_x"] = global_position.x
	WordList.spawned_letters[id]["global_position_y"] = global_position.y
	WordList.spawned_letters[id]["rotation_degrees"] = global_rotation_degrees


func move_to(
	target_position: Vector2,
	target_rotation: float,
	moved_to_whom: int,
	cell_index: int,
	holding_bar_condition: bool = false,
	skip_interpolate: bool = false,
	in_holding_bar: bool = false
) -> void:

	# Stop previous tween if running
	if _is_moving and _move_tween and _move_tween.is_running():
		_move_tween.kill()

	# Update states
	_in_holding_bar = in_holding_bar
	_is_moving = true
	$Tap.button_pressed = holding_bar_condition
	$Tap.disabled = true

	# Bring to front
	get_parent().call_deferred(
		"move_child",
		self,
		get_parent().get_child_count() - 1
	)

	$PushInTimer.stop()

	# Play scoring animation if ownership changes
	if WordList.spawned_letters[id]["owned_by"] != moved_to_whom:
		$AnimParticle.play("Scoring")

	# Update ownership info
	WordList.spawned_letters[id]["owned_by"] = moved_to_whom
	WordList.spawned_letters[id]["cell_index"] = cell_index

	if moved_to_whom == Globals.LetterOwnership.BOARD_OPPONENT:
		_is_expiring = false

	# Set target
	_target_position = target_position

	# Optional drop animation: start slightly above
	var start_position = position
	if not skip_interpolate:
		start_position -= Vector2(0, 150)
		position = start_position

	# Create tween
	_move_tween = create_tween()
	_move_tween.set_parallel(true)

	# Tween position to target
	_move_tween.tween_property(
		self,
		"position",
		_target_position,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Tween rotation
	_move_tween.tween_property(
		self,
		"rotation_degrees",
		target_rotation,
		1.0
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Connect finished signal
	_move_tween.finished.connect(_on_move_finished)


func _on_move_finished() -> void:
	# Snap exactly
	position = _target_position
	rotation_degrees = 0.0

	_is_moving = false
	$Tap.disabled = false



func _physics_process(_delta):
	if !_is_moving:
		global_rotation = lerp_angle(global_rotation, 0.0, 0.25)




func select(is_picked: bool = true, is_auto: bool = true) -> void:
	# Physics handling (GD3 MODE_STATIC replacement)
	if is_picked:
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	else:
		freeze = false

	# Emit correct signal
	if is_auto:
		emit_signal("letter_autopicked", id, is_picked)
	else:
		emit_signal("letter_picked", id, is_picked)

	# Picked state
	if is_picked:
		$AnimTap.play("tap")
		_is_held = true

		# Cancel expiration while held
		if _is_expiring:
			_is_expiring = false

		# Bring to front
		get_parent().call_deferred(
			"move_child",
			self,
			get_parent().get_child_count() - 1
		)
	else:
		# Released state
		$AnimTap.play_backwards("tap")
		_is_held = false



func deselect(is_auto: bool=true) -> void:
	select(false, is_auto)


func depress() -> void:
	$Tap.button_pressed = false
	
	
func disable(is_disabled: bool=true) -> void:
	$Tap.disabled = is_disabled


func force_disable(is_disabled: bool=true) -> void:
	_forced_disable = is_disabled


func expire() -> void:
	if _is_expiring:
		return

	_is_expiring = true

	# First phase: 3 cycles of shake
	for n in 3:
		if not _is_expiring:
			return
		
		var shake_tween1 = create_tween()
		shake_tween1.tween_property($LetterSprite, "rotation_degrees", 15, 2 - (0.5 * n)) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		
		var shake_tween2 = create_tween()
		shake_tween2.tween_property($LetterSprite, "rotation_degrees", -15, 4 - (1 * n)) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT) \
			.set_delay(2 - (0.5 * n))
		
		var shake_tween3 = create_tween()
		shake_tween3.tween_property($LetterSprite, "rotation_degrees", 0, 2 - (0.5 * n)) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT) \
			.set_delay(6 - (1.5 * n))
		
		await shake_tween3.finished
	
	# Second phase: 6 faster cycles
	for n in 6:
		if not _is_expiring and n < 3:
			return
		
		var shake_tween1 = create_tween()
		shake_tween1.tween_property($LetterSprite, "rotation_degrees", 15, 0.3 - (0.05 * n)) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		
		var shake_tween2 = create_tween()
		shake_tween2.tween_property($LetterSprite, "rotation_degrees", -15, 0.6 - (0.1 * n)) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT) \
			.set_delay(0.3 - (0.05 * n))
		
		var shake_tween3 = create_tween()
		shake_tween3.tween_property($LetterSprite, "rotation_degrees", 0, 0.3 - (0.05 * n)) \
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT) \
			.set_delay(0.9 - (0.15 * n))
		
		await shake_tween3.finished
		
		if n == 3:
			deselect(false)
			if id in WordList.get_spawned_letters_owned_by(Globals.LetterOwnership.POOL):
				$Tap.disabled = true
				WordList.remove_spawned_letter(id)
	
	queue_free()


func tween_win_lose_move(to: Vector2, duration: float, delay: float) -> void:
	var t = create_tween()
	t.tween_property(self, "global_position", to, duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN) \
		.set_delay(delay)


func tween_win_lose_fade(duration: float, delay: float) -> void:
	var t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN) \
		.set_delay(delay)


func _on_Tap_pressed() -> void:
	var board = get_tree().root.get_node("Game/Pool/BoardMe")
	
	# Check if the board already has 7 picked letters
	if board._picked_letters.size() >= 7:
		$Tap.release()  # Release the button properly
		return
	
	# Play the letter selection sound
	Audio.play_sfx(Audio.Sfx.LETTER_SELECTED)
	
	# Call select() on this letter
	select(true, false)


func _on_PushInTimer_timeout() -> void:
	if global_position.x < _PUSH_IN_MARGIN or global_position.x > get_viewport_rect().size.x - _PUSH_IN_MARGIN:
		var direction = Vector2(get_viewport_rect().size.x / 2 - global_position.x, global_position.y).normalized()
		apply_impulse(direction * Vector2.RIGHT * _PUSH_IN_FORCE, Vector2.ZERO)


# Removed old signal connections for TweenMove/TweenMove2/TweenExpire etc.
# The completion logic is now handled via tween.finished signals or callbacks as shown above.

func _exit_tree() -> void:
	queue_free()
