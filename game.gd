extends Node2D

@export var is_muted_music: bool = false
@export var is_muted_sfx: bool = false
@export var is_server: bool = false

var _has_pool_started: bool = false

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	await get_tree().create_timer(0.1).timeout
	Audio.set_mute_music(GameLoader.player_data["settings"]["is_muted_music"])
	Audio.set_mute_sfx(GameLoader.player_data["settings"]["is_muted_sfx"])
	
	# Connect quit request signal
	get_tree().quit_requested.connect(_on_quit_request)

func _on_quit_request() -> void:
	if not _has_pool_started:
		Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_QUIT_REQUEST, Analytics.login_params)
		Loading.load_next(null, null, null, 0.1, true)
		await Loading.screen_loaded
		get_tree().quit()


func _on_Home_game_started(mode: int, level: int) -> void:
	WordList.set_parameters(level)
	$Pool.dropdown_UI_reset()
	if mode == Globals.GameMode.VS_AI:
		$Tutorial.stop()
		$Pool.start_alternate(level)
	elif mode == Globals.GameMode.TUTORIAL:
		$Tutorial.tutorial_part = level
		$Tutorial.replay_level = level < GameLoader.player_data["current_level"]
		$Pool.start_tutorial(level)


func _on_Home_custom_game_started(mode, this_opponent: int, word_mix_level: String, ai_dictionary_level: String, ai_reaction_level: int, custom_point_condition: int):
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_CUSTOM_PLAYED, {
		"custom_opponent_choice": this_opponent,
		"custom_opponent_difficulty_level": ai_reaction_level,
		"custom_opponent_dictionary_level": ai_dictionary_level,
		"custom_word_mix_level": word_mix_level,
		"custom_target_points": custom_point_condition
	})
	WordList.set_custom_parameters(word_mix_level, ai_dictionary_level)
	$Pool.dropdown_UI_reset()
	$Pool.start_custom(this_opponent, custom_point_condition, ai_reaction_level)
	$Tutorial.stop()


func _on_Home_visibility_changed() -> void:
	if $Home_New.visible:
		_has_pool_started = false
		if Audio._last_played_music != 0:
			Audio.play_music(Audio.Music.MUSIC_HOME)
		if GameLoader.get_save_data("tutorial_intro") != 0:
			$Tutorial.start_intro(true)
	else:
		_has_pool_started = true


func _on_Pool_pool_started(mode: int, level: int = 0) -> void:
	if mode == Globals.GameMode.TUTORIAL:
		$Tutorial.start_gameplay_layer($Pool, $Commander, $Pool/BoardMe, $Pool/BoardOpponent)
	else:
		# Directly call a method on Commander, no Callable needed
		$Commander.start_game(mode, level)  # Implement this method in Commander


func _on_Pool_pool_finished() -> void:
	$Home_New.start()
	$Commander.stop()


func _on_Pool_letter_spawned(letter: Letter) -> void:
	letter.connect("letter_picked", Callable($Pool/EventManager, "_on_letter_picked"))


func _on_Pool_letters_snatched(from_who: int, longest_word: String, picked_letters: Array, steal: Array) -> void:
	$Tutorial.letters_snatched(from_who, longest_word, picked_letters)
	$Commander.letters_snatched(from_who, longest_word, picked_letters)
	if from_who == 1:
		match len(picked_letters):
			3: GameLoader.update_achievement_value("achievement_form_3","points",1)
			4: GameLoader.update_achievement_value("achievement_form_4","points",1)
			5: GameLoader.update_achievement_value("achievement_form_5","points",1)
			6: GameLoader.update_achievement_value("achievement_form_6","points",1)
			7: GameLoader.update_achievement_value("achievement_form_7","points",1)
		for a in picked_letters:
			match a.letter:
				"j": GameLoader.update_achievement_value("achievement_form_with_j","points",1)
				"x": GameLoader.update_achievement_value("achievement_form_with_x","points",1)
				"q": GameLoader.update_achievement_value("achievement_form_with_q","points",1)
				"z": GameLoader.update_achievement_value("achievement_form_with_z","points",1)
		if steal[0] != false:
			match steal[1]:
				3: GameLoader.update_achievement_value("achievement_steal_3","points",1)
				4: GameLoader.update_achievement_value("achievement_steal_4","points",1)
				5: GameLoader.update_achievement_value("achievement_steal_5","points",1)


func _on_Pool_picker_command_succeeded(command: Array) -> void:
	$Commander.picker_command_succeeded(command)


func _on_Pool_result_announced(who_won: int, mode: int, _points: Dictionary, _longest_word, _best_word) -> void:	
	var who_lost: int = Globals.LetterOwnership.BOARD_OPPONENT
	if who_won == Globals.LetterOwnership.BOARD_OPPONENT:
		who_lost = Globals.LetterOwnership.BOARD_ME
	
	if who_won == Globals.LetterOwnership.BOARD_ME:
		pass  # Keep AI booster unlocking logic here

	if not $Pool.get_node("BoosterManager").return_event_type($Pool._ai_level) and $Pool._ai_level != 0:
		$Pool/BoosterManager.check_consumed_booster()
	if $Pool._ai_level < GameLoader.player_data["current_level"] and $Pool._ai_level != 0:
		GameLoader.update_achievement_value("achievement_replay_level", "points", 1)
	
	var current_best_words: Array = GameLoader.player_data["best_word_list"]
	var record_best_words: Array = get_tree().root.get_node("Game/Pool").best_word_list
	for words in record_best_words:
		if not current_best_words.has([words[0], words[1]]):
			current_best_words.append(words)
	current_best_words.sort_custom(Callable(CustomSorter, "sort_descending"))
	if current_best_words.size() > 10:
		current_best_words.resize(10)
	GameLoader.player_data["best_word_list"] = current_best_words
	
	$Commander.stop()
	GameLoader.save_game()
	GameLoader.overwrite_achievement_value()
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_POINTS_ACQUIRED, Analytics.points_params(get_tree().root.get_node("Game/Pool")._ai_level, _points))


func _on_Commander_command_issued(command: Array) -> void:
	$Pool.command(command)


func _on_Commander_spawn_command(is_issued: bool) -> void:
	$Pool.check_spawn_command(is_issued)


func _on_Commander_ai_level_set(ai_level: int) -> void:
	pass


func _on_Tutorial_name_changed(name: String) -> void:
	$Home_New.set_player_name(name)


func _on_Login_login_checked(is_logged_in: bool = true) -> void:
	$Home_New.show()
	if GameLoader.get_save_data("tutorial_intro") != 0:
		$Tutorial.show()
	else:
		$Tutorial.hide()


class CustomSorter:
	static func sort_descending(a, b):
		return a[0] > b[0]
