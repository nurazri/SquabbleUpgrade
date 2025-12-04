extends Control

signal game_started(mode)
signal custom_game_started(mode)
signal page_changed(page_type)


@onready var header_UI: Control = $Header_UI/New_Header
@onready var footer_UI: Control = $Header_UI/New_Footer

var max_scroll_distance: int = 0
var custom_scroll_dist = [0,1135,1135,1190,1260,1260]

var current_page: int = Globals.PageType.HOME
var last_check_in: Dictionary = {}

var limit_scroll: int = 0


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameLoader.connect("game_saved", Callable(self, "_on_GameLoader_game_saved"))
	GameLoader.connect("achievement_saved", Callable(self, "_on_GameLoader_achievement_saved"))
	GameLoader.connect("currency_saved", Callable(self, "on_currency_changed"))
	start()


func _process(delta) -> void:
	if $ScrollContainer.get_v_scroll() <= max_scroll_distance:
		$ScrollContainer.set_v_scroll(max_scroll_distance + 1)


func start() -> void:
	set_avatar(GameLoader.get_save_data("avatar"))
	on_currency_changed()
	on_stage_updated()
	
	#Audio.play_music(Audio.Music.MUSIC_HOME)


func _on_redirect_page(this_page: int, extra_params: String) -> void:
	change_page(this_page, extra_params)


func change_page(page: int, extra_parameters: String = "") -> void:
	var previous_page = footer_UI.get_node("HBoxContainer/" + Globals.PageButtons[current_page])
	var new_page = footer_UI.get_node("HBoxContainer/" + Globals.PageButtons[page])
	
	if Globals.PageButtons[current_page] != "":
		if Globals.PageButtons[current_page] == "Adventure":
			header_UI.get_node("Location").hide()
		$TweenButton.interpolate_property(previous_page, "custom_minimum_size", previous_page.custom_minimum_size, Vector2(166, 136), 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(previous_page.get_node("TextureRect"), "modulate", previous_page.modulate, Color(1, 1, 1, 1), 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(previous_page.get_node("Label"), "position:y", 135, 195, 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(previous_page.get_node("Icon"), "position", Vector2(34, -31), Vector2(32, 24), 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(previous_page.get_node("Icon"), "size", Vector2(198, 164), Vector2(108, 88), 0.15, Tween.TRANS_LINEAR)
	
	if Globals.PageButtons[page] != "":
		if Globals.PageButtons[page] == "Adventure":
			header_UI.get_node("Location").show()
		$TweenButton.interpolate_property(new_page, "custom_minimum_size", new_page.custom_minimum_size, Vector2(260, 190), 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(new_page.get_node("TextureRect"), "modulate", previous_page.modulate, Color(0.92, 0.39, 1, 1), 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(new_page.get_node("Label"), "position:y", 195, 135, 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(new_page.get_node("Icon"), "position", Vector2(32, 24), Vector2(34, -31), 0.15, Tween.TRANS_LINEAR)
		$TweenButton.interpolate_property(new_page.get_node("Icon"), "size", Vector2(108, 88), Vector2(198, 164), 0.15, Tween.TRANS_LINEAR)
	
	$TweenButton.start()
	if Globals.PageName[current_page] != "":
		get_node(Globals.PageName[current_page]).hide()
	if Globals.PageName[page] != "":
		get_node(Globals.PageName[page]).extra_params = extra_parameters
		get_node(Globals.PageName[page]).show()
		
	current_page = page


func play_level(this_level: int = 0, play_sfx: bool = true, play_animation: bool = false) -> void:
	if GameLoader.player_data["current_level"] < this_level:
		return

	if play_sfx:
		Audio.play_sfx(Audio.Sfx.BUTTON_TAP)
	#if play_animation:
	#	$AnimationPlayer.play("Homescreen_Exit")
	#	yield($AnimationPlayer, "animation_finished")
	
	hide()
	var this_game_mode: int = 0
	if this_level <= 7:
		this_game_mode = Globals.GameMode.TUTORIAL
		if this_level == 1:
			Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_TUTORIAL_BEGIN, Analytics.level_params(this_level))
			ByteBrew.new_progression_event(ByteBrew.ProgressionType.Started, "Tutorial", "Level " + str(this_level))
	else:
		this_game_mode = Globals.GameMode.VS_AI
		
	Loading.load_next(null, null, null)
	await Loading.screen_loaded
	emit_signal("game_started", this_game_mode, this_level)
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_LEVEL_PLAYED, Analytics.level_params(this_level))
	ByteBrew.new_progression_event(ByteBrew.ProgressionType.Started, "Level", "Level " + str(this_level))


func play_custom_game(this_opponent: int, word_mix_level: String, ai_dictionary_level: String, ai_reaction_level: int, custom_point_condition: int) -> void:
	Audio.play_sfx(Audio.Sfx.BUTTON_TAP)
	change_page(Globals.PageType.HOME)
	modulate = Color(0,0,0,0)
	$Header_UI/New_Header.modulate = Color(0,0,0,0)
	$Header_UI/New_Footer.modulate = Color(0,0,0,0)
	$Header_UI/Blocker.show()
	Loading.load_next(null, null, null)
	await $TweenButton.tween_all_completed
	hide()
	modulate = Color(1,1,1,1)
	$Header_UI/New_Header.modulate = Color(1,1,1,1)
	$Header_UI/New_Footer.modulate = Color(1,1,1,1)
	$Header_UI/Blocker.hide()
	await Loading.screen_loaded
	emit_signal("custom_game_started", Globals.GameMode.VS_AI, this_opponent, word_mix_level, ai_dictionary_level, ai_reaction_level, custom_point_condition)


func set_avatar(which: int) -> void:
	header_UI.get_node("Header/Avatar/Character").texture = Globals.AvatarTextures[which]
	header_UI.get_node("Header/Avatar/Label").text = Globals.AvatarNames[which]


func _on_GameLoader_game_saved() -> void:
	set_avatar(GameLoader.get_save_data("avatar"))
	on_currency_changed()
	on_stage_updated()
	$Profile_Page.on_Load()
	$Inventory_Page.on_Load()


func _on_GameLoader_achievement_saved() -> void:
	$Achievement_Page.reload()
	$Profile_Page.on_Load()
	$Inventory_Page.on_Load()


func on_currency_changed() -> void:
	_set_player_coins(GameLoader.load_currency("coins"))
	_set_player_diamonds(GameLoader.load_currency("diamonds"))


func on_stage_updated() -> void:
	var this_level = 1
	for i in range(1,10):
		for levels in get_node("ScrollContainer/VBoxContainer/Background"+ str(i) +"/Level_List").get_children():
			if this_level > Globals.currentLevelLimit:
				levels.init(this_level, 0, 0)
			else:
				levels.init(this_level, GameLoader.player_data["level_progression"][str(this_level)]["completion"], GameLoader.player_data["level_progression"][str(this_level)]["rating"])
				if !levels.is_connected("start_level", Callable(self, "play_level")):
					levels.connect("start_level", Callable(self, "play_level"))
			
			this_level += 1
	
	var current_stage: int = get_current_stage()
	for clouds in $ScrollContainer/Cloud_List.get_children():
		clouds.hide()
	get_node("ScrollContainer/Cloud_List/Cloud_Overlay" + str(current_stage)).show()
	max_scroll_distance = 13323 - (custom_scroll_dist[current_stage] * current_stage)


func _set_player_coins(coin: int) -> void:
	header_UI.get_node("Header/Coin/UserCoin").text = str(coin)


func _set_player_diamonds(diamond: int) -> void:
	header_UI.get_node("Header/Diamond/UserDiamond").text = str(diamond)


func update_header(coin, diamond) -> void:
	on_currency_changed()


func _attempt_daily_login_feature() -> void:
	var get_datetime: Dictionary = Time.get_datetime_dict_from_system()
	var fetch_datetime: Dictionary = GameLoader.player_data["last_logged_in"]
	if get_datetime["day"] > fetch_datetime["day"]:
		var get_day_difference = get_datetime["day"] - fetch_datetime["day"]
		if get_day_difference > 1:
			_popup_daily_reward()
		else:
			if get_datetime["hour"] > 12:
				_popup_daily_reward()
	elif get_datetime["month"] > fetch_datetime["month"]:
		_popup_daily_reward()
	elif get_datetime["year"] > fetch_datetime["year"]:
		_popup_daily_reward()
	
	last_check_in = get_datetime


func _popup_daily_reward() -> void:
	$DailyReward_UI/Daily_Reward.show()


func on_daily_reward_claimed() -> void:
	GameLoader.player_data["last_logged_in"]["day"] = last_check_in["day"]
	GameLoader.player_data["last_logged_in"]["month"] = last_check_in["month"]
	GameLoader.player_data["last_logged_in"]["year"] = last_check_in["year"]
	GameLoader.player_data["last_logged_in"]["hour"] = last_check_in["hour"]
	GameLoader.player_data["last_logged_in"]["minute"] = last_check_in["minute"]
	
	GameLoader.save_currency("diamonds", 1)
	GameLoader.save_game()
	$DailyReward_UI/Daily_Reward.hide()


func _on_Home_visibility_changed() -> void:
	if visible:
		$AnimationPlayer.play("Homescreen_Entrance")
	header_UI.show() if visible else header_UI.hide()
	footer_UI.show() if visible else footer_UI.hide()
	
	#1135 for separation
	var current_stage: int = get_current_stage()
	for clouds in $ScrollContainer/Cloud_List.get_children():
		clouds.hide()
	
	await get_tree().create_timer(0.01).timeout
	max_scroll_distance = 13323 - (custom_scroll_dist[current_stage] * current_stage)
	$ScrollContainer.set_v_scroll(max_scroll_distance)
	get_node("ScrollContainer/Cloud_List/Cloud_Overlay" + str(current_stage)).show()
	await get_tree().create_timer(0.25).timeout
	if GameLoader.player_data["completed_tutorial"] == true:
		_attempt_daily_login_feature()


func get_current_stage() -> int:
	var get_stage: int = GameLoader.player_data["current_level"]
	var set_stage: int = 0
	get_stage = get_stage - 7
	for i in range(0,5):
		if get_stage <= (i * 10):
			set_stage = i
			break
		set_stage = i
	
	get_stage = set_stage
	return get_stage
