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

# =========================
# Core Reward / Progression
# =========================
func _save_progression_reward(achieved_stars: int, level: int) -> void:
	if achieved_stars <= 0:
		return

	var level_data = GameLoader.player_data["level_progression"][str(level)]
	if achieved_stars > level_data["rating"]:
		var reward_3star = level_data["rewardtype"]["3"]
		var reward_2star = level_data["rewardtype"]["2"]
		var reward_amount_3star = level_data["rewardamount"]["3"]
		var reward_amount_2star = level_data["rewardamount"]["2"]

		if achieved_stars == 3:
			if reward_3star != "booster":
				_create_reward(reward_3star, reward_amount_3star)
			else:
				_create_reward(reward_3star, reward_amount_3star, level_data["extra"])

			if level_data["rating"] != 2:
				if reward_2star != "booster":
					_create_reward(reward_2star, reward_amount_2star)
				else:
					_create_reward(reward_2star, reward_amount_2star, level_data["extra"])
		elif achieved_stars == 2:
			if reward_2star != "booster":
				_create_reward(reward_2star, reward_amount_2star)
			else:
				_create_reward(reward_2star, reward_amount_2star, level_data["extra"])

		if level != GameLoader.player_data["current_level"]:
			GameLoader.set_level_progression_data(level, achieved_stars, false)
		else:
			GameLoader.set_level_progression_data(level, achieved_stars)

func _create_reward(type, amount, extra: Dictionary = {}) -> void:
	var reward_object: Node
	match type:
		"coins":
			reward_object = _ScnResultReward.instantiate()
			GameLoader.save_currency("coins", amount)
			reward_object.init(amount, 2)
			$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)
		"diamonds":
			reward_object = _ScnResultReward.instantiate()
			GameLoader.save_currency("diamonds", amount)
			reward_object.init(amount, 3)
			$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)
		"booster":
			if typeof(amount) == TYPE_ARRAY:
				for i in range(amount.size()):
					reward_object = _ScnResultReward.instantiate()
					var makeshift_dict: Dictionary = {"type": 0, "tier": 0}
					GameLoader.player_data["booster_owned"][str(extra["type"][i])][str(extra["tier"][i])] += 1
					makeshift_dict.type = extra["type"][i]
					makeshift_dict.tier = extra["tier"][i]
					reward_object.init(amount[i], 1, makeshift_dict)
					$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)
			else:
				reward_object = _ScnResultReward.instantiate()
				GameLoader.player_data["booster_owned"][str(extra["type"])][str(extra["tier"])] += 1
				reward_object.init(amount, 1, extra)
				$Result_Win/RewardsBg/Holder/RewardContainer.add_child(reward_object)

# =====================
# Result Announcement
# =====================
func on_custom_result_announced(coin: int = 0, gem: int = 0) -> void:
	show()
	_set_buttons("Tutorial")
	var level = get_tree().root.get_node("Game/Pool")._ai_level
	if level == 7:
		Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_TUTRORIAL_COMPLETE, Analytics.level_params(level))
		ByteBrew.new_progression_event(ByteBrew.ProgressionType.Completed, "Tutorial", "Level " + str(level))

	current = "Winner"
	for i in range(1, 4):
		get_node("Result_Win/Star0" + str(i)).show()
	_set_best_word("Win")
	
	animation_result_new.play("Winner")
	await animation_result_new.animation_finished
	animation_result_new.play("ResultScreen_Winner")
	
	Audio.play_music(Audio.Music.MUSIC_WIN)
	_save_progression_reward(3, level)

# =====================
# Win/Lose Result Logic
# =====================
func _on_Pool_result_announced(who_won: int, _mode: int, points: Dictionary, longest_word, points_from_longest_word) -> void:
	show()
	if not Appodeal.is_ad_loaded(Appodeal.AdType.REWARDED_VIDEO):
		Appodeal.load_ad(Appodeal.AdType.REWARDED_VIDEO)
	
	var level = get_tree().root.get_node("Game/Pool")._ai_level
	var achieved_stars = 0
	if level != 0:
		if who_won == Globals.LetterOwnership.BOARD_ME:
			var level_review = get_tree().root.get_node("Game/Pool/UI/LevelReview")
			level_review.update_condition_win_status(points[Globals.LetterOwnership.BOARD_ME], points[Globals.LetterOwnership.BOARD_OPPONENT])
			achieved_stars = level_review.return_stars()
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

	for n in range(achieved_stars):
		get_node("Result_Win/Star0" + str(n+1)).show()

	_set_win_screen_animation_new(who_won)
	if level != 0:
		_save_progression_reward(achieved_stars, level)

	$Result_Win/InterfaceType/NoAds/NextLevel/NinePatchRect/Btn_NextLevel.disabled = (level + 1) > Globals.currentLevelLimit
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_STARS_ACQUIRED, Analytics.stars_params(level, points, achieved_stars))

# =====================
# Win Screen Animations
# =====================
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
	if not get_tree().root.get_node("Game/Pool/EventManager").has_ended:
		get_tree().root.get_node("Game/Pool/EventManager")._progress_event()

# =====================
# Best Word Display
# =====================
func _set_best_word(type: String) -> void:
	var get_words: Array = get_tree().root.get_node("Game/Pool").best_word_list
	if get_words.size() == 0:
		return
	var count = 1
	for i in range(1, 6):
		get_node("Result_" + type + "/WordBg" + str(i) + "/Word").text = get_words[get_words.size() - count][1]
		count += 1
		if count > get_words.size():
			break

# =====================
# UI Button Handling
# =====================
func _set_buttons(type: String) -> void:
	$Result_Win/InterfaceType/NoAds.visible = false
	$Result_Win/InterfaceType/Ads.visible = false
	$Result_Win/InterfaceType/Tutorial.visible = false
	$Result_Win/InterfaceType/Custom.visible = false
	$Result_Win/InterfaceType/CustomAds.visible = false
	match type:
		"Standard": $Result_Win/InterfaceType/NoAds.visible = true
		"Standard-Ads": $Result_Win/InterfaceType/Ads.visible = true
		"Tutorial": $Result_Win/InterfaceType/Tutorial.visible = true
		"Custom": $Result_Win/InterfaceType/Custom.visible = true
		"Custom-Ads": $Result_Win/InterfaceType/CustomAds.visible = true
