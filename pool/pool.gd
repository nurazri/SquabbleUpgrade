extends CommandInterpreter

signal pool_started
signal pool_finished
signal letter_spawned
signal letters_snatched
signal picker_command_succeeded
signal result_announced

const _GAME_OVER_TIMEOUT: float = 30.0
const _INACTIVE_TIMEOUT: float = 12.0

@export var _disabled_toggle_panel: Texture2D
@export var _enabled_toggle_panel: Texture2D
@export var _disabled_bgm_icon: Texture2D
@export var _enabled_bgm_icon: Texture2D
@export var _disabled_sfx_icon: Texture2D
@export var _enabled_sfx_icon: Texture2D
@export var _dropdown_expanded: Texture2D
@export var _dropdown_collapse: Texture2D

var _REQUIRED_POINT: int = 0
var debug_keys_tapped: int = 0

var _mode: int = Globals.GameMode.NONE
var _type: int = Globals.GameType.STANDARD
var _is_game_started: bool = false
var _is_game_over: bool = false

var _is_spawning: bool = false
var _is_spawner_commands_finished: bool = false
var _ai_level: int = 1
var _simulated_ai_level: int = 0

var _points := {
	Globals.LetterOwnership.BOARD_ME: 0,
	Globals.LetterOwnership.BOARD_OPPONENT: 0
}

var _longest_words := {
	Globals.LetterOwnership.BOARD_ME: "",
	Globals.LetterOwnership.BOARD_OPPONENT: ""
}

var _best_word := {
	Globals.LetterOwnership.BOARD_ME: "",
	Globals.LetterOwnership.BOARD_OPPONENT: ""
}

var best_word_list: Array = []


# --------------------------------------------------
# READY / NOTIFICATION
# --------------------------------------------------

func _ready() -> void:
	hide()
	$UI/LevelReview.player_board_ref = $BoardMe


func _notification(what: int) -> void:
	if not visible:
		return

	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			if _mode != Globals.GameMode.TUTORIAL \
			and not $UI/Countdown.visible \
			and not _is_game_over:
				pass


# --------------------------------------------------
# POOL SETUP
# --------------------------------------------------

func setup_pool(level, mode, type) -> void:
	get_tree().call_group("lettertiles", "queue_free")

	_is_game_over = false
	_is_game_started = false
	_ai_level = level

	if _ai_level > Globals.currentLevelLimit:
		_ai_level = Globals.currentLevelLimit

	_reset_scoring()

	_mode = mode
	_type = type
	$GameOverTimer.set_mode(mode)

	$TilesCounter.reset()
	$Spawner.reset()
	$Picker.reset()
	$Picker.set_boards($BoardMe, $BoardOpponent)
	$BoosterManager.set_boards($BoardMe, $BoardOpponent)

	if level != 0:
		$Level.text = "LEVEL " + str(_ai_level)
		if mode == Globals.GameMode.VS_AI:
			$UI/LevelReview.fetch_level_condition(_ai_level)
			$UI/LevelReview.show()
			$UI/LevelReview/Panel/Header_Level.text = "Level " + str(_ai_level)
			$UI/LevelReview/Panel/Requirement_1_Star.text = \
				"Score more than " + str(_REQUIRED_POINT) + " points"
		else:
			$UI/LevelReview.hide()

	get_tree().call_group(
		"boards",
		"reset",
		mode,
		Globals.GameType.SPEEDPLAY,
		_REQUIRED_POINT,
		false
	)
	get_tree().call_group("boards", "show_info")
	show()


func check_spawn_command(is_issued: bool) -> void:
	_is_spawning = is_issued


# --------------------------------------------------
# PLAYER / OPPONENT SETUP
# --------------------------------------------------

func _set_opponent(level) -> void:
	for i in Globals.OpponentList:
		if level >= Globals.OpponentList[i]["Min_Level"] \
		and level <= Globals.OpponentList[i]["Max_Level"]:
			_REQUIRED_POINT = Globals.OpponentList[i]["Point_Requirement"]
			#$BoardOpponent.set_name(Globals.OpponentList[i]["Name"]) #no need set name for now, if later have problem need to change
			$BoardOpponent.set_avatar(
				Globals.OpponentList[i]["Avatar"],
				Globals.OpponentList[i]["Avatar_BG"]
			)
			break


func _set_self() -> void:
	var avatar_index: int = GameLoader.get_save_data("avatar")
	$BoardMe.set_avatar(
		Globals.AvatarTextures[avatar_index],
		Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_ME]
	)


# --------------------------------------------------
# GAME MODES
# --------------------------------------------------

func start_alternate(level) -> void:
	_type = Globals.GameType.SPEEDPLAY
	_set_opponent(level)
	_set_self()
	$Level.show()
	$TilesCounter.hide()
	setup_pool(level, Globals.GameMode.VS_AI, Globals.GameType.SPEEDPLAY)
	Audio.stop_music()


func start_custom(simulate_opponent: int, simulate_target_points: int, simulate_level: int) -> void:
	_type = Globals.GameType.SPEEDPLAY

	$BoardOpponent.set_name(Globals.OpponentList[simulate_opponent]["Name"])
	$BoardOpponent.set_avatar(
		Globals.OpponentList[simulate_opponent]["Avatar"],
		Globals.OpponentList[simulate_opponent]["Avatar_BG"]
	)

	_REQUIRED_POINT = simulate_target_points
	_simulated_ai_level = simulate_level

	$Level.text = "Custom Game"
	_set_self()
	$Level.show()
	$TilesCounter.hide()
	setup_pool(0, Globals.GameMode.VS_AI, Globals.GameType.SPEEDPLAY)
	Audio.stop_music()
	_start_stage(true, simulate_level)


func start_tutorial(level) -> void:
	_type = Globals.GameType.STANDARD
	setup_pool(level, Globals.GameMode.TUTORIAL, Globals.GameType.STANDARD)
	emit_signal("pool_started", Globals.GameMode.TUTORIAL, _ai_level)
	$EventManager.check_event(level)
	get_tree().call_group("boards", "show_snatch_button")
	_is_game_started = true


# --------------------------------------------------
# GAME FLOW
# --------------------------------------------------

func _start_stage(is_custom_game_mode := false, override_ai_level := 0) -> void:
	Audio.play_random_play_music()
	$UI/Countdown.show()
	await $UI/Countdown/Anim.animation_finished

	get_tree().call_group("lettertiles", "disable", false)
	get_tree().call_group("lettertiles", "force_disable", false)

	if not is_custom_game_mode:
		if $BoosterManager.return_event_type(_ai_level):
			$BoosterManager.set_temp_booster(_ai_level)
		else:
			$BoosterManager.set_equipped_booster()

	$BoardMe.enable_snatch_button(true)
	$BoardMe.enable_snatch_swipe(true)
	$BoardMe.enable_reset(true)
	$BoardMe.enable_boosters(true)
	get_tree().call_group("boards", "show_snatch_button")

	emit_signal(
		"pool_started",
		Globals.GameMode.VS_AI,
		override_ai_level if override_ai_level != 0 else _ai_level
	)

	_is_game_started = true
	
func command(command: Array) -> void:
	if not _is_game_over:
		match command[0]:
			"s":
				if _ai_level >= 28 and _ai_level <= 47:
					$Spawner._enable_rotation = true 
				else:
					$Spawner._enable_rotation = false
				$Spawner.command(command)
			"m":
				if _ai_level <= 7:
					if _points[Globals.LetterOwnership.BOARD_OPPONENT] < 20:
						$Picker.command(command)
					else:
						return
				else:
					if $BoardOpponent._can_interact:
						$Picker.command(command)


# --------------------------------------------------
# SCORING 
# --------------------------------------------------

func _reset_scoring() -> void:
	_points[Globals.LetterOwnership.BOARD_ME] = 0
	_points[Globals.LetterOwnership.BOARD_OPPONENT] = 0

	_longest_words[Globals.LetterOwnership.BOARD_ME] = ""
	_longest_words[Globals.LetterOwnership.BOARD_OPPONENT] = ""

	_best_word[Globals.LetterOwnership.BOARD_ME] = ""
	_best_word[Globals.LetterOwnership.BOARD_OPPONENT] = ""

	best_word_list.clear()
	
func _start_scoring_animation(points: int, who: int, origin_x: float, origin_y: float) -> void:

	var get_anim_idx: int = 0
	if who == Globals.LetterOwnership.BOARD_ME:
		$Scoring_Me/Score.text = str(points)
		get_anim_idx = $AnimationPlayer.get_animation("Scoring").find_track("Scoring_Me/Score:rect_position",Animation.TYPE_VALUE)
		$AnimationPlayer.get_animation("Scoring").track_set_key_value(get_anim_idx, 0, Vector2(origin_x + 25, origin_y - 150))
		$AnimationPlayer.get_animation("Scoring").track_set_key_value(get_anim_idx, 1, Vector2(origin_x + 25, origin_y - 150))
		$AnimationPlayer.get_animation("Scoring").track_set_key_value(get_anim_idx, 2, Vector2(origin_x - 15, origin_y - 247))
		$AnimationPlayer.get_animation("Scoring").track_set_key_value(get_anim_idx, 3, Vector2(220, 100))
		$AnimationPlayer.play("Scoring")
	if who == Globals.LetterOwnership.BOARD_OPPONENT:
		$Scoring_Opponent/Score.text = str(points)
		#get_anim_idx = $AnimationPlayer2.get_animation("Scoring").find_track("Scoring_Opponent/Score:rect_position")
		
		var anim: Animation = $AnimationPlayer2.get_animation("Scoring")
		var track_path: NodePath = NodePath("Scoring_Opponent/Score:rect_position")

		var get_anim_idx1: int = -1  # -1 means not found

		for i in anim.get_track_count():
			if anim.track_get_path(i) == track_path:
				get_anim_idx1 = i
				break
		
		$AnimationPlayer2.get_animation("Scoring").track_set_key_value(get_anim_idx, 0, Vector2(origin_x + 25, origin_y - 150))
		$AnimationPlayer2.get_animation("Scoring").track_set_key_value(get_anim_idx, 1, Vector2(origin_x + 25, origin_y - 150))
		$AnimationPlayer2.get_animation("Scoring").track_set_key_value(get_anim_idx, 2, Vector2(700, 100))
		$AnimationPlayer2.play("Scoring")


func _on_points_updated(points: int, who_am_i: int, insert_point: Vector2) -> void:
	if points > _points[who_am_i] && _ai_level != 1: 
		var set_point = points - _points[who_am_i]
		_start_scoring_animation(set_point, who_am_i, insert_point.x, insert_point.y)
		
	_points[who_am_i] = points
	if not _is_game_over && _type == Globals.GameType.SPEEDPLAY:
		$GameOverTimer.set_points(_points)
		
		if _points[who_am_i] >= _REQUIRED_POINT:
			_is_game_over = true
			emit_signal("result_announced", who_am_i, _mode, _points, _longest_words[Globals.LetterOwnership.BOARD_ME], _best_word[Globals.LetterOwnership.BOARD_ME])


func _on_Spawner_letter_spawned(letter: Letter) -> void:
	get_tree().call_group("boards", "connect_spawned_letter", letter)
	letter.letter_picked.connect($BoardMe._on_letter_picked)
	emit_signal("letter_spawned", letter)

func _on_Spawner_commands_finished() -> void:
	_is_spawner_commands_finished = true
	if not _mode == Globals.GameMode.TUTORIAL:
		if WordList.get_spawned_letters_quantity_left() <= 0 and $GameOverTimer.wait_time > _INACTIVE_TIMEOUT:
			$GameOverTimer.start(_INACTIVE_TIMEOUT)
			print("[Pool] letter tiles stopped spawning, no more letter tiles available!")


func _on_Picker_command_succeeded(command: Array) -> void:
	emit_signal("picker_command_succeeded", command)


func _on_letters_snatched(from_who: int, spelled_word: String, longest_word: String, best_word: String, picked_letters: Array, steal: Array) -> void:
	_longest_words[from_who] = longest_word
	_best_word[from_who] = best_word
	
	if from_who == Globals.LetterOwnership.BOARD_ME:
		var total_points: int = 0
		for letters in picked_letters:
			total_points += WordList.get_letter_points(letters.letter)

		if not best_word_list.has([total_points, spelled_word]):
			best_word_list.push_back([total_points, spelled_word])

		best_word_list.sort_custom(Callable(CustomSorter, "sort_ascending"))

		if _ai_level > 7:
			$UI/LevelReview.update_condition_letters_picked(picked_letters, steal, total_points)
	
	$GameOverTimer.set_longest_words(_longest_words)
	$GameOverTimer.set_best_words(_best_word)
	print("[Pool] longest word from " + str(from_who) + " is " + longest_word)
	emit_signal("letters_snatched", from_who, longest_word, picked_letters, steal)
	



func _on_GameOverTimer_game_over() -> void:
	_is_game_over = true
	$ShowTicksGameOverTimer.stop()


func _on_GameOverTimer_result_announced(who_won: int, game_mode: int, points: Dictionary, longest_word, points_from_longest_word) -> void:
	emit_signal("result_announced", who_won, game_mode, points, longest_word, points_from_longest_word)


func _on_ShowTicksGameOverTimer_timeout() -> void:
	if visible and not _is_game_over:
		print("[Pool] game over timer countdown: >>>>>>" + str(round($GameOverTimer.time_left)) + "<<<<<<")


func _on_Btn_Start_Level_pressed() -> void:
	$UI/LevelReview.hide()
	if $EventManager.check_event(_ai_level):
		return
		
	_start_stage()


var _dropdown_tween: Tween


func dropdown_UI_reset() -> void:
	if _dropdown_tween:
		_dropdown_tween.kill()

	$Btn_DropdownMenu/TextureRect.texture = _dropdown_expanded
	$Panel_Dropdown/Backdrop.visible = false
	$Panel_Dropdown/Backdrop.position = Vector2(-6, -120)

	_on_Btn_Toggle_BGM_pressed(false)
	_on_Btn_Toggle_SFX_pressed(false)


func _on_Btn_DropdownMenu_pressed() -> void:
	if _dropdown_tween:
		_dropdown_tween.kill()

	if !$Panel_Dropdown/Backdrop.visible:
		$Panel_Dropdown/Backdrop.visible = true
		$Btn_DropdownMenu/TextureRect.texture = _dropdown_collapse

		_dropdown_tween = create_tween()
		_dropdown_tween.set_trans(Tween.TRANS_BOUNCE)
		_dropdown_tween.set_ease(Tween.EASE_OUT)

		_dropdown_tween.tween_property(
			$Panel_Dropdown/Backdrop,
			"position",
			Vector2(-6, -10),
			0.5
		)

	else:
		$Btn_DropdownMenu/TextureRect.texture = _dropdown_expanded
		$Panel_Dropdown/Backdrop.visible = false
		$Panel_Dropdown/Backdrop.position = Vector2(-6, -120)



func _on_Btn_Toggle_BGM_pressed(_externally_pressed: bool = true) -> void:
	if _externally_pressed:
		Audio._is_muted_music = !Audio._is_muted_music
		Audio.set_mute_music(Audio._is_muted_music)
		GameLoader.player_data["settings"]["is_muted_music"] = Audio._is_muted_music
	if !Audio._is_muted_music:
		$Panel_Dropdown/Backdrop/Btn_Toggle_BGM/Panel.texture = _enabled_toggle_panel
		$Panel_Dropdown/Backdrop/Btn_Toggle_BGM/Icon.texture = _enabled_bgm_icon
	if Audio._is_muted_music:
		$Panel_Dropdown/Backdrop/Btn_Toggle_BGM/Panel.texture = _disabled_toggle_panel
		$Panel_Dropdown/Backdrop/Btn_Toggle_BGM/Icon.texture = _disabled_bgm_icon


func _on_Btn_Toggle_SFX_pressed(_externally_pressed: bool = true) -> void:
	if _externally_pressed:
		Audio._is_muted_sfx = !Audio._is_muted_sfx
		Audio.set_mute_sfx(Audio._is_muted_sfx)
		GameLoader.player_data["settings"]["is_muted_sfx"] = Audio._is_muted_music
	if !Audio._is_muted_sfx:
		$Panel_Dropdown/Backdrop/Btn_Toggle_SFX/Panel.texture = _enabled_toggle_panel
		$Panel_Dropdown/Backdrop/Btn_Toggle_SFX/Icon.texture = _enabled_sfx_icon
	if Audio._is_muted_sfx:
		$Panel_Dropdown/Backdrop/Btn_Toggle_SFX/Panel.texture = _disabled_toggle_panel
		$Panel_Dropdown/Backdrop/Btn_Toggle_SFX/Icon.texture = _disabled_sfx_icon


func _on_Btn_Return_Home_pressed() -> void:
	if _is_game_started:
		_is_game_over = true
		get_parent().get_node("Commander").stop()
		$EventManager.has_ended = true
		$EventManager.reset_fake_boosters()
		$UI/WinLose.return_home()


# --------------------------------------------------
# SORTER
# --------------------------------------------------

class CustomSorter:
	static func sort_ascending(a, b):
		return a[0] < b[0]

func _on_Btn_SkipLevel_pressed():
	if Globals.debug_tools && visible:
		if !_is_game_over && _is_game_started:
			debug_keys_tapped += 1
			if debug_keys_tapped == 2:
				_is_game_over = true
				$UI/LevelReview.debug_condition()
				emit_signal("result_announced", Globals.LetterOwnership.BOARD_ME, _mode, _points, _longest_words[Globals.LetterOwnership.BOARD_ME], _best_word[Globals.LetterOwnership.BOARD_ME])
				debug_keys_tapped = 0
		elif _ai_level < 8 && _is_game_started:
			debug_keys_tapped += 1
			if debug_keys_tapped == 2:
				_is_game_started = false
				$EventManager.manual_transition_result_screen()
				debug_keys_tapped = 0


func _on_Btn_SkipStage_pressed():
	if Globals.debug_tools && !visible:
		print("Skip stage")
		if GameLoader.player_data["current_level"] < Globals.currentLevelLimit + 1:
			var current_level = GameLoader.player_data["current_level"]
			if current_level >= 7:
				GameLoader.player_data["completed_tutorial"] = true
			if current_level >= 10:
				GameLoader.player_data["unlocked_booster_slot"][0] = 1
				GameLoader.player_data["booster_parameters"]["1"]["Discovered"] = 1
				GameLoader.player_data["booster_parameters"]["1"]["Discovered_Tier_1"] = 1
			if current_level >= 14:
				GameLoader.player_data["booster_parameters"]["1"]["Discovered_Tier_2"] = 1
				GameLoader.player_data["booster_parameters"]["1"]["Discovered_Tier_3"] = 1
			if current_level >= 17:
				GameLoader.player_data["unlocked_booster_slot"][1] = 1
				GameLoader.player_data["has_rated"] = true
			if current_level >= 30:
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.BLAST)]["Discovered"] = 1
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.BLAST)]["Discovered_Tier_1"] = 1
			if current_level >= 34:
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.BLAST)]["Discovered_Tier_2"] = 1
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.BLAST)]["Discovered_Tier_3"] = 1
			if current_level >= 38:
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.PROTECT)]["Discovered"] = 1
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.PROTECT)]["Discovered_Tier_1"] = 1
			if current_level >= 42:
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.PROTECT)]["Discovered_Tier_2"] = 1
				GameLoader.player_data["booster_parameters"][str(Globals.BoosterType.PROTECT)]["Discovered_Tier_3"] = 1
			if current_level >= 46:
				GameLoader.player_data["unlocked_booster_slot"][2] = 1
			
			GameLoader.set_level_progression_data(current_level, 1, true)
			
			
