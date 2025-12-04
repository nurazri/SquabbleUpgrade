extends Node2D

signal return_main_menu

const _SHOW_ADS_EVERY: int = 3

@export var _ScnLetter: PackedScene
@export var _ScnResultReward: PackedScene

var _longest_word: String = ""

var current: String = ""

@onready var point_timer: Timer = $PointsUpdateTimer
@onready var animation_result_new: AnimationPlayer = $AnimationPlayer

var _admob_counter: int = 0


func _ready() -> void:
	Appodeal.connect("rewarded_ad_finished", Callable(self, "_on_Appodeal_rewarded_ad_finished"))


func on_custom_result_announced(coin: int = 0, gem: int = 0) -> void:
	show()
	
	_set_buttons("Tutorial")
	var level = get_tree().root.get_node("Game/Pool")._ai_level
	if level == 7:
		Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_TUTRORIAL_COMPLETE, Analytics.level_params(level))
		ByteBrew.new_progression_event(ByteBrew.ProgressionType.Completed, "Tutorial", "Level " + str(level))

	current = "Winner"
	get_node("Result_Win/Star01").show()
	get_node("Result_Win/Star02").show()
	get_node("Result_Win/Star03").show()
	_set_best_word("Win")
	
	animation_result_new.play("Winner")
	await animation_result_new.animation_finished
	animation_result_new.play("ResultScreen_Winner")
	
	Audio.play_music(Audio.Music.MUSIC_WIN)
	_save_progression_reward(3, level)


func _on_Pool_result_announced(who_won: int, _mode: int, points: Dictionary, longest_word, points_from_longest_word) -> void:
	show()
	if not Appodeal.is_ad_loaded(Appodeal.AdType.REWARDED_VIDEO):
		Appodeal.load_ad(Appodeal.AdType.REWARDED_VIDEO)
	
	var level = get_tree().root.get_node("Game/Pool")._ai_level
	var achieved_stars = 0
	if level != 0:
		if who_won == Globals.LetterOwnership.BOARD_ME:
			get_tree().root.get_node("Game/Pool/UI/LevelReview").update_condition_win_status(points[Globals.LetterOwnership.BOARD_ME], points[Globals.LetterOwnership.BOARD_OPPONENT])
			achieved_stars = get_tree().root.get_node("Game/Pool/UI/LevelReview").return_stars()
			_create_reward("coins", 50)
			Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_LEVEL_COMPLETE, Analytics.level_params(level))
			ByteBrew.new_progression_event(ByteBrew.ProgressionType.Completed, "Level", "Level " + str(level), achieved_stars)
			if Appodeal.is_ad_loaded(Appodeal.AdType.REWARDED_VIDEO):
				_set_buttons("Standard-Ads")
			else:
				_set_buttons("Standard")
	else:
		var simulated_level = get_tree().root.get_node("Game/Pool")._simulated_ai_level
		match simulated_level:
			17: _create_reward("coins", 25)
			47: _create_reward("coins", 50)
			77: _create_reward("coins", 100)
			107: _create_reward("diamonds", 1)
		
		achieved_stars = 3
		if Appodeal.is_ad_loaded(Appodeal.AdType.REWARDED_VIDEO):
			_set_buttons("Custom-Ads")
		else:
			_set_buttons("Custom")
	
	if who_won == Globals.LetterOwnership.BOARD_OPPONENT:
		ByteBrew.new_progression_event(ByteBrew.ProgressionType.Failed, "Level", "Level " + str(level))
	
	for n in achieved_stars:
		get_node("Result_Win/Star0" + str(n+1)).show()
	
	_set_win_screen_animation_new(who_won)
	if level != 0:
		_save_progression_reward(achieved_stars, level)
	
	if (level + 1) > Globals.currentLevelLimit:
		$Result_Win/InterfaceType/NoAds/NextLevel/NinePatchRect/Btn_NextLevel.disabled = true
	else:
		$Result_Win/InterfaceType/NoAds/NextLevel/NinePatchRect/Btn_NextLevel.disabled = false

	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_STARS_ACQUIRED, Analytics.stars_params(level, points, achieved_stars))


func _set_win_screen_animation_new(who_won: int) -> void:
	match who_won:
		Globals.LetterOwnership.BOARD_ME:
			current = "Winner"
			get_tree().root.get_node("Game/Pool/EventManager").extra_params = "win"
			animation_result_new.play(current)
			await animation_result_new.animation_finished
			Audio.play_music(Audio.Music.MUSIC_WIN)
			_set_best_word("Win")
			
		Globals.LetterOwnership.BOARD_OPPONENT:
			current = "Loser"
			get_tree().root.get_node("Game/Pool/EventManager").extra_params = "lose"
			animation_result_new.play(current)
			await animation_result_new.animation_finished
			Audio.play_music(Audio.Music.MUSIC_LOSE)
			_set_best_word("Lose")
			
	animation_result_new.play("ResultScreen_" + str(current))
	await animation_result_new.animation_finished
	if !get_tree().root.get_node("Game/Pool/EventManager").has_ended:
		get_tree().root.get_node("Game/Pool/EventManager")._progress_event()


func _set_buttons(type: String) -> void:
	$Result_Win/InterfaceType/NoAds.visible = false
	$Result_Win/InterfaceType/Ads.visible = false
	$Result_Win/InterfaceType/Tutorial.visible = false
	$Result_Win/InterfaceType/Custom.visible = false
	$Result_Win/InterfaceType/CustomAds.visible = false
	match type:
		"Standard":
			$Result_Win/InterfaceType/NoAds.visible = true
		"Standard-Ads":
			$Result_Win/InterfaceType/Ads.visible = true
		"Tutorial":
			$Result_Win/InterfaceType/Tutorial.visible = true
		"Custom":
			$Result_Win/InterfaceType/Custom.visible = true
		"Custom-Ads":
			$Result_Win/InterfaceType/CustomAds.visible = true


func _set_best_word(type: String) -> void:
	var get_words: Array = get_tree().root.get_node("Game/Pool").best_word_list
	if get_words.size() != 0:
		var count = 1
		for best_words in range(1,6):
			get_node("Result_" + type + "/WordBg" + str(best_words) + "/Word").text = get_words[get_words.size() - count][1]
			count += 1
			if count > get_words.size():
				break


func _save_progression_reward(achieved_stars: int, level: int) -> void:
	if achieved_stars > 0:
		if achieved_stars > GameLoader.player_data["level_progression"][str(level)]["rating"]:
			var reward_3star = GameLoader.player_data["level_progression"][str(level)]["rewardtype"]["3"]
			var reward_2star = GameLoader.player_data["level_progression"][str(level)]["rewardtype"]["2"]
			var reward_amount_3star = GameLoader.player_data["level_progression"][str(level)]["rewardamount"]["3"]
			var reward_amount_2star = GameLoader.player_data["level_progression"][str(level)]["rewardamount"]["2"]
			
			if achieved_stars == 3:
				if reward_3star != "booster":
					_create_reward(reward_3star, reward_amount_3star)
				else:
					_create_reward(reward_3star, reward_amount_3star, GameLoader.player_data["level_progression"][str(level)]["extra"])
				
				if GameLoader.player_data["level_progression"][str(level)]["rating"] != 2:
					if reward_2star != "booster":
						_create_reward(reward_2star, reward_amount_2star)
					else:
						_create_reward(reward_2star, reward_amount_2star, GameLoader.player_data["level_progression"][str(level)]["extra"])

			elif achieved_stars == 2:
				if reward_2star != "booster":
					_create_reward(reward_2star, reward_amount_2star)
				else:
					_create_reward(reward_2star, reward_amount_2star, GameLoader.player_data["level_progression"][str(level)]["extra"])
			
			if level != GameLoader.player_data["current_level"]:
				GameLoader.set_level_progression_data(level, achieved_stars, false)
			else:
				GameLoader.set_level_progression_data(level, achieved_stars)


func _create_reward(type, amount, extra: Dictionary = {}) -> void:
	match type:
		"coins":
			var reward_object = _ScnResultReward.instantiate()
			GameLoader.save_currency("coins", amount)
			reward_object.init(amount, 2)
			$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)
		"diamonds":
			var reward_object = _ScnResultReward.instantiate()
			GameLoader.save_currency("diamonds", amount)
			reward_object.init(amount, 3)
			$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)
		"booster":
			if typeof(amount) == TYPE_ARRAY:
				for i in range(0, amount.size()):
					var reward_object = _ScnResultReward.instantiate()
					var makeshift_dictionary: Dictionary = {"type": 0, "tier": 0}
					GameLoader.player_data["booster_owned"][str(extra["type"][i])][str(extra["tier"][i])] += 1
					makeshift_dictionary.type = extra["type"][i]
					makeshift_dictionary.tier = extra["tier"][i]
					reward_object.init(amount[i], 1, makeshift_dictionary)
					$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)
			else:
				var reward_object = _ScnResultReward.instantiate()
				GameLoader.player_data["booster_owned"][str(extra["type"])][str(extra["tier"])] += 1
				reward_object.init(amount, 1, extra)
				$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)


func _reinitialize_reward() -> void:
	for reward in $Result_Win/RewardsBg/Holder/RewardContainer.get_children():
		reward.reinit()
		match reward._type:
			"coins":
				GameLoader.save_currency("coins", reward._amount)
			"diamonds":
				GameLoader.save_currency("diamonds", reward._amount)
			"booster":
				GameLoader.player_data["booster_owned"][str(reward._extra["type"])][str(reward._extra["tier"])] += 1


func reset_results() -> void:
	$Result_Win/InterfaceType/Tutorial/NextTutorial/NinePatchRect/Btn_NextTutorial.disabled = true
	$Result_Win/InterfaceType/NoAds/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = true
	$Result_Win/InterfaceType/NoAds/NextLevel/NinePatchRect/Btn_NextLevel.disabled = true
	$Result_Win/InterfaceType/Ads/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = true
	$Result_Win/InterfaceType/Ads/NextLevel/NinePatchRect/Btn_NextLevel.disabled = true
	$Result_Win/InterfaceType/Ads/WatchAds/NinePatchRect/Btn_DoubleReward.disabled = true
	$Result_Win/InterfaceType/Custom/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = true
	$Result_Win/InterfaceType/CustomAds/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = true
	$Result_Win/InterfaceType/CustomAds/WatchAds/NinePatchRect/Btn_DoubleReward.disabled = true
	
	$Result_Lose/ReplayLevel/NinePatchRect/Btn_ReplayLevel.disabled = true
	$Result_Lose/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = true
	
	
	animation_result_new.play("ResultScreen_" + current + "_End")
	await animation_result_new.animation_finished
	
	$Result_Win/InterfaceType/Tutorial/NextTutorial/NinePatchRect/Btn_NextTutorial.disabled = false
	$Result_Win/InterfaceType/NoAds/NextLevel/NinePatchRect/Btn_NextLevel.disabled = false
	$Result_Win/InterfaceType/NoAds/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = false
	$Result_Win/InterfaceType/Ads/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = false
	$Result_Win/InterfaceType/Ads/NextLevel/NinePatchRect/Btn_NextLevel.disabled = false
	$Result_Win/InterfaceType/Ads/WatchAds/NinePatchRect/Btn_DoubleReward.disabled = false
	$Result_Win/InterfaceType/Custom/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = false
	$Result_Win/InterfaceType/CustomAds/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = false
	$Result_Win/InterfaceType/CustomAds/WatchAds/NinePatchRect/Btn_DoubleReward.disabled = false
	
	$Result_Lose/ReplayLevel/NinePatchRect/Btn_ReplayLevel.disabled = false
	$Result_Lose/ReturnHome/NinePatchRect/Btn_ReturnHome.disabled = false
	$Result_Win/InterfaceType/Ads/WatchAds/NinePatchRect.modulate = Color(1,1,1,1)
	$Result_Win/InterfaceType/CustomAds/WatchAds/NinePatchRect.modulate = Color(1,1,1,1)
	
	for best_words in range(1,5):
		get_node("Result_Win/WordBg" + str(best_words) + "/Word").text = ""
		get_node("Result_Lose/WordBg" + str(best_words) + "/Word").text = ""
	
	get_tree().root.get_node("Game/Pool/EventManager").reset_fake_boosters()
	hide()
	#animation_result_new.play("RESET")
	
	for i in range(1,4) :
		get_node("Result_Win/Star0" + str(i)).hide()
	for child in get_node("Result_Win/RewardsBg/Holder/RewardContainer").get_children():
		child.queue_free()


func return_home() -> void:
	hide()
	get_tree().root.get_node("Game/Pool").hide()
	Loading.load_next(null, null, null)
	await Loading.screen_loaded
	get_tree().root.get_node("Game/Home_New").show()


func play_level(next: bool) -> void:
	var level = get_tree().root.get_node("Game/Pool")._ai_level
	if next:
		get_tree().root.get_node("Game/Home_New").play_level(level + 1, false)
	else:
		get_tree().root.get_node("Game/Home_New").play_level(level, false)


func _on_Btn_NextTutorial_pressed() -> void:
	_btn_is_pressed(true, get_tree().root.get_node("Game/Tutorial").replay_level)


func _on_Btn_ReturnHome_pressed() -> void:
	_btn_is_pressed(false, true)


func _on_Btn_NextLevel_pressed() -> void:
	_btn_is_pressed(true)


func _on_Btn_ReplayLevel_pressed() -> void:
	_btn_is_pressed()
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_LEVEL_RETRIED, Analytics.level_params(get_tree().root.get_node("Game/Pool")._ai_level))


func _btn_is_pressed(next_level: bool = false, return_home: bool = false) -> void:
	Audio.play_sfx(Audio.Sfx.BUTTON_TAP)
	reset_results()
	_show_ads_if_condition()
	await animation_result_new.animation_finished
	if return_home:
		return_home()
		return
	else:
		play_level(next_level)


func _on_Btn_DoubleReward_pressed():
	_show_ads_now(Appodeal.AdType.REWARDED_VIDEO)
	$Result_Win/InterfaceType/Ads/WatchAds/NinePatchRect/Btn_DoubleReward.disabled = true
	$Result_Win/InterfaceType/CustomAds/WatchAds/NinePatchRect/Btn_DoubleReward.disabled = true
	$Result_Win/InterfaceType/Ads/WatchAds/NinePatchRect.modulate = Color(0.75,0.75,0.75,1)
	$Result_Win/InterfaceType/CustomAds/WatchAds/NinePatchRect.modulate = Color(0.75,0.75,0.75,1)


func _show_ads_if_condition() -> void:
	var level = get_tree().root.get_node("Game/Pool")._ai_level
	if level == 7:
		print(GameLoader.player_data["current_level"])
		_show_ads_now()
		_admob_counter += 1
		print("[AdMob] AdMob counter: " + str(_admob_counter))
		return
	if !GameLoader.player_data["completed_tutorial"]:
		return
	
	if visible:
		_admob_counter += 1
		print("[AdMob] AdMob counter: " + str(_admob_counter))
		if _admob_counter >= _SHOW_ADS_EVERY:
			_show_ads_now()
			_admob_counter %= _SHOW_ADS_EVERY
			print("[AdMob] Showing ads every " + str(_SHOW_ADS_EVERY) + " time(s)")


func _show_ads_now(ad_type: int = Appodeal.AdType.INTERSTITIAL) -> void:
	if not Appodeal.is_ad_loaded(ad_type):
		Appodeal.load_ad(ad_type)
		var wait_for: String = "interstitial_loaded"
		match ad_type:
			Appodeal.AdType.INTERSTITIAL:
				wait_for = "interstitial_loaded"
			Appodeal.AdType.REWARDED_VIDEO:
				wait_for = "rewarded_ad_loaded"
		await Appodeal.wait_for

	Appodeal.show_ad(ad_type)
	
	if Appodeal.is_ad_loaded(ad_type):
		var wait_for: String = "interstitial_opened"
		match ad_type:
			Appodeal.AdType.INTERSTITIAL:
				wait_for = "interstitial_opened"
			Appodeal.AdType.REWARDED_VIDEO:
				wait_for = "rewarded_ad_opened"
		await Appodeal.wait_for

	GameLoader.update_achievement_value("achievement_watch_ads", "points", 1)
	GameLoader.overwrite_achievement_value()

	if not Appodeal.is_ad_loaded(ad_type):
		Appodeal.load_ad(ad_type)


func _on_Appodeal_rewarded_ad_finished(amount: float, currency: String) -> void:
	print("Amount: " + str(amount) + ", Currency:"  + str(currency))
	GameLoader.update_achievement_value("achievement_watch_ads", "points", 1)
	GameLoader.overwrite_achievement_value()
	
	_reinitialize_reward()
	GameLoader.save_game()
