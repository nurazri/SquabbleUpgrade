extends Node2D

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
			$BoardOpponent.set_name(Globals.OpponentList[i]["Name"])
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


# --------------------------------------------------
# SCORING (FIXED — THIS WAS MISSING)
# --------------------------------------------------

func _reset_scoring() -> void:
	_points[Globals.LetterOwnership.BOARD_ME] = 0
	_points[Globals.LetterOwnership.BOARD_OPPONENT] = 0

	_longest_words[Globals.LetterOwnership.BOARD_ME] = ""
	_longest_words[Globals.LetterOwnership.BOARD_OPPONENT] = ""

	_best_word[Globals.LetterOwnership.BOARD_ME] = ""
	_best_word[Globals.LetterOwnership.BOARD_OPPONENT] = ""

	best_word_list.clear()


# --------------------------------------------------
# SORTER
# --------------------------------------------------

class CustomSorter:
	static func sort_ascending(a, b):
		return a[0] < b[0]
