extends Node2D

# General Params
var this_level: int = 0
var step: int = 1
var has_ended: bool = true
var extra_params: String = "none"

var levels_with_events: Array = [1, 3, 6, 10]
var levels_with_dialogs: Array = [1, 2, 3, 4, 5, 6, 7, 8, 10, 14, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 34, 36, 37, 38, 41, 44, 47, 108, 118]

signal start_stage

#For events
@export var _ScnLetter: PackedScene

@export var _OVERLAY_CENTER: Texture2D
@export var _OVERLAY_SNATCH: Texture2D
@export var _OVERLAY_TILES: Texture2D
@export var _OVERLAY_POINTS: Texture2D

var _picked_letters: Array = []
var retry: bool = false

@onready var _dialog_manager: Control = $DialogLayer/DialogManager
@onready var _static_dialog_manager: Control = $StaticDialogLayer/StaticDialogManager

@onready var _BoardMe: Node2D = get_parent().get_node("BoardMe")
@onready var _BoardOpponent: Node2D = get_parent().get_node("BoardOpponent")
@onready var _Commander: Node2D = get_tree().root.get_node("Game/Commander")


func check_event(level) -> bool:
	var has_event: bool = false
	_dialog_manager.reset_dialog()
	_dialog_manager.enable_dialog_text(false)
	_static_dialog_manager.enable_static_text(false)
	reset_fake_boosters()
	_picked_letters.clear()
	step = 1
	
	this_level = level
	if levels_with_dialogs.has(level):
		has_event = true
		has_ended = false
		extra_params = "none"
		
		initiate_event(this_level, step, true)
	
	return has_event


func initiate_event(level, step, init = false) -> void:
	$CanvasLayer/Overlay.hide()
	match level:
		1: #Starting level, guide to picking letters
			if init:
				pass
				
			print("after pass at step: " + str(step))
			match step:
				1: 
					set_custom_avatar_expression("Squab", "yousee3")
					_static_dialog_manager.start_static_text("This game is about forming words")
				2: 
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("This is how you form words")
				3: 
					set_custom_avatar_expression("Squab", "point")
					set_overlay(_OVERLAY_CENTER)
					_static_dialog_manager.start_static_text("Letters will slide in from the sides")
					manual_command_letter(["w", "e", "l", "l"], true)
				4: 
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("Form your first word now")
				5: 
					set_custom_avatar_expression("Squab", "yousee")
					_static_dialog_manager.start_static_text("Tap on W", true)
					toggle_highlight(0)
				6: 
					set_custom_avatar_expression("Squab", "yousee2")
					_static_dialog_manager.start_static_text("Then E", true)
				7: 
					set_custom_avatar_expression("Squab", "yousee")
					_static_dialog_manager.start_static_text("Now L", true)
				8: 
					set_custom_avatar_expression("Squab", "yousee2")
					_static_dialog_manager.start_static_text("And the other L", true)
				9: 
					set_overlay(_OVERLAY_SNATCH)
					set_custom_avatar_expression("Squab", "yousee3")
					_static_dialog_manager.start_static_text("Tap Snatch", true)
				10: 
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("Well, that's how you form words")
				11: 
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("Let's try form a second word")
					manual_command_letter(["d", "o", "n", "e"], true)
				12: 
					set_custom_avatar_expression("Squab", "yousee")
					_static_dialog_manager.start_static_text("Tap on D", true)
					toggle_highlight(4)
				13: 
					set_custom_avatar_expression("Squab", "yousee2")
					_static_dialog_manager.start_static_text("Tap on O", true)
				14: 
					set_custom_avatar_expression("Squab", "yousee")
					_static_dialog_manager.start_static_text("Tap on N", true)
				15: 
					set_custom_avatar_expression("Squab", "yousee2")
					_static_dialog_manager.start_static_text("Tap on E", true)
				16: 
					set_cursor(true)
					set_custom_avatar_expression("Squab", "yousee3")
					_static_dialog_manager.start_static_text("This time, swipe downwards to Snatch the word", true)
				17: 
					set_cursor(false)
					set_custom_avatar_expression("Squab", "smile")
					_static_dialog_manager.start_static_text("Well done newbie. Now you know how to form letters")
				18: 
					set_custom_avatar_expression("Squab", "god")
					_static_dialog_manager.start_static_text("Next let's teach you how to win")
				19: manual_transition_result_screen()
		2: #Sandbox mode, make score marker visible
			match step:
				1: 
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("Now let's teach you how to win")
				2: 
					#Enable highlight
					set_overlay(_OVERLAY_POINTS)
					set_custom_avatar_expression("Squab", "yousee")
					_static_dialog_manager.start_static_text("Each level has a target points to win shown here")
				3: 
					set_overlay(_OVERLAY_POINTS)
					set_custom_avatar_expression("Squab", "provoke")
					_static_dialog_manager.start_static_text("This level requires 15 points to win. You now have zero")
				4: 
					set_custom_avatar_expression("Squab", "point")
					_static_dialog_manager.start_static_text("The word you form determines your points")
				5: 
					#Disable Highlight
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("Try forming words on your own this time to score 15 points")
				6:
					#Enable Game
					_Commander.get_node("SpawnCommand").start_command(Globals.GameMode.ENDLESS)
					_static_dialog_manager.enable_static_text(false)
					set_snatch_function(true)
				7: 
					_Commander.stop()
					set_custom_avatar_expression("Squab", "smile")
					_static_dialog_manager.start_static_text("Not bad... you're smarter than the previous fella")
				8: 
					set_custom_avatar_expression("Squab", "normal")
					_static_dialog_manager.start_static_text("So now you know the basics")
				9: 
					set_custom_avatar_expression("Squab_Drink", "lookatyou2")
					_static_dialog_manager.start_static_text("Time for some intermediate skills")
				10: manual_transition_result_screen()
		3: #Guide players with forming words with existing creation
			match step:
				1: 
					set_custom_avatar_expression("Squab_Drink", "lookatyou2")
					_static_dialog_manager.start_static_text("Here you will learn how to extend words")
				2: 
					set_custom_avatar_expression("Squab_Drink", "lookatyou")
					_static_dialog_manager.start_static_text("Start by forming the word ME", true)
					manual_command_letter(["m", "e"], true)
					toggle_highlight(0)
				3: 
					set_custom_avatar_expression("Squab_Drink", "point")
					_static_dialog_manager.start_static_text("Now tap on C, O, ME. Slide down or tap Snatch", true)
					manual_command_letter(["c", "o"], true)
					toggle_highlight(2)
				4: 
					set_custom_avatar_expression("Squab_Drink", "lookatyou")
					_static_dialog_manager.start_static_text("Form longer words this way to score bonus points")
				5: 
					set_custom_avatar_expression("Squab_Drink", "lookatyou")
					_static_dialog_manager.start_static_text("4 letter words gives 1 bonus point")
				6: 
					set_custom_avatar_expression("Squab_Drink", "point")
					_static_dialog_manager.start_static_text("Now try and form the word WELCOME", true)
					manual_command_letter(["w", "e", "l"], true)
					toggle_highlight(4)
				7: 
					set_custom_avatar_expression("Squab_Drink", "proud")
					_static_dialog_manager.start_static_text("You just formed a 7 letter word! That's 7 bonus points!")
				8: 
					set_custom_avatar_expression("Squab_Drink_Norm", "")
					_static_dialog_manager.start_static_text("With this you have earned 22 points. Enough to pass the level!")
				9: manual_transition_result_screen()
		4: #Sandbox mode again, make tile marker visible
			if retry:
				match step:
					1: 
						set_custom_avatar_expression("Squab", "provoke")
						_static_dialog_manager.start_static_text("You ran out of tiles, let's try again")
					2:
						set_custom_avatar_expression("Squab_Drink_Norm", "")
						_Commander.get_node("SpawnCommand").start_command(Globals.GameMode.TUTORIAL)
						_static_dialog_manager.enable_static_text(false)
						set_snatch_function(true)
					3:
						_Commander.stop()
						set_custom_avatar_expression("Squab_Drink", "stun")
						_static_dialog_manager.start_static_text("Hmm... now you're smarter than most of the previous fellas")
					4: 
						retry = false
						manual_transition_result_screen()
			else:
				match step:
					1: 
						set_custom_avatar_expression("Squab_Drink", "lookatyou2")
						_static_dialog_manager.start_static_text("Try completing this level by yourself. The winning score is 25")
					2: 
						set_custom_avatar_expression("Squab_Drink", "lookatyou")
						_static_dialog_manager.start_static_text("Be sure to get 25 points before the tiles run out ")
					3: 
						set_overlay(_OVERLAY_TILES)
						set_custom_avatar_expression("Squab_Drink", "point")
						_static_dialog_manager.start_static_text("Look here to see tiles left")
					4:
						set_custom_avatar_expression("Squab_Drink_Norm", "")
						#Disable Highlight, Enable Game
						_Commander.get_node("SpawnCommand").start_command(Globals.GameMode.TUTORIAL)
						_static_dialog_manager.enable_static_text(false)
						set_snatch_function(true)
					5: 
						_Commander.stop()
						set_custom_avatar_expression("Squab_Drink", "stun")
						_static_dialog_manager.start_static_text("Hmm... now you're smarter than most of the previous fellas")
					6: manual_transition_result_screen()
		5: #Sandbox mode Un, Deux, Trois, nothing special here except for the last part
			if retry:
				match step:
					1: 
						set_custom_avatar_expression("Squab", "provoke")
						_static_dialog_manager.start_static_text("You ran out of tiles, let's try again")
					2:
						set_custom_avatar_expression("Squab_Drink_Norm", "")
						_Commander.get_node("SpawnCommand").start_command(Globals.GameMode.TUTORIAL)
						_static_dialog_manager.enable_static_text(false)
						set_snatch_function(true)
					3: 
						_Commander.stop()
						set_custom_avatar_expression("Squab_Drink", "stun2")
						_static_dialog_manager.start_static_text("Pfft... that was fast! I barely had a sip of my coffee. Right now")
					4: manual_transition_result_screen(true)
					5: 
						_dialog_manager.anim_player.play("new_entrance_2")
						_dialog_manager.start_dialog_text("Are you briefing newbies again?", 3, "Quabble", "right", false)
					6:
						_dialog_manager.anim_player.play("alt_entrance_1")
						_dialog_manager.start_dialog_text("Quabble! Go away! Go AWAY!", 6, "Squab", "left", false)
					7: _dialog_manager.start_dialog_text("Hey newbie... I bet Squab is teaching you garbage", 6, "Quabble", "right")
					8: _dialog_manager.start_dialog_text("Shut up! My teachings are great. I bet \"newbie\" here can beat you anytime.", 1, "Squab", "left")
					9: _dialog_manager.start_dialog_text("blah blah blah... proove it. ", 1, "Quabble", "right")
					10: 
						retry = false
						_dialog_manager.enable_dialog_text(false)
			else:
				match step:
					1: 
						set_custom_avatar_expression("Squab_Drink", "annoy")
						_static_dialog_manager.start_static_text("Now let's raise the bar a little.")
					2: 
						set_custom_avatar_expression("Squab_Drink", "annoy")	
						_static_dialog_manager.start_static_text("Win by earning 30 points before the tiles run out yourself.")
					3: 
						set_custom_avatar_expression("Squab_Drink", "annoy")
						_static_dialog_manager.start_static_text("I'm gonna finish my coffee.")
					4:
						#Enable Game
						set_custom_avatar_expression("Squab_Drink_Norm", "")
						_Commander.get_node("SpawnCommand").start_command(Globals.GameMode.TUTORIAL)
						_static_dialog_manager.enable_static_text(false)
						set_snatch_function(true)
					5: 
						_Commander.stop()
						set_custom_avatar_expression("Squab_Drink", "stun2")
						_static_dialog_manager.start_static_text("Pfft... that was fast! I barely had a sip of my coffee. Right now")
					6: manual_transition_result_screen(true)
					7: 
						_dialog_manager.anim_player.play("new_entrance_2")
						_dialog_manager.start_dialog_text("Are you briefing newbies again?", 3, "Quabble", "right", false)
					8:
						_dialog_manager.anim_player.play("alt_entrance_1")
						_dialog_manager.start_dialog_text("Quabble! Go away! Go AWAY!", 6, "Squab", "left", false)
					9: _dialog_manager.start_dialog_text("Hey newbie... I bet Squab is teaching you garbage", 6, "Quabble", "right")
					10: _dialog_manager.start_dialog_text("Shut up! My teachings are great. I bet \"newbie\" here can beat you anytime.", 1, "Squab", "left")
					11: _dialog_manager.start_dialog_text("blah blah blah... proove it. ", 1, "Quabble", "right")
					12: _dialog_manager.enable_dialog_text(false)
		6: #First tutorial battle, guide to steal words
			if init:
				manual_setter(["w","i","r","e"], [[0,1,2,3]])
			match step:
				1: 
					_dialog_manager.avatar2.texture = load("res://avatar/expression/Quabble3.png")
					_dialog_manager.anim_player.play("new_entrance_1")
					_dialog_manager.anim_player.seek(2.0, false)
					await get_tree().create_timer(0.03).timeout
					_dialog_manager.anim_player.play("new_entrance_2")
					_dialog_manager.anim_player.seek(2.0, false)
					await get_tree().create_timer(0.03).timeout
					_dialog_manager.start_dialog_text("Alright newbie, the real game starts now", 4, "Squab", "left")
				2: _dialog_manager.start_dialog_text("Quabble will try to score 30 points faster than you. You need to", 5, "Squab", "left")
				3: _dialog_manager.start_dialog_text("You done yet? I'm about to sleep", 9, "Quabble", "right")
				4: _dialog_manager.start_dialog_text("Shut it you feline fiend! Newbie, you can win this", 1, "Squab", "left")
				5: _dialog_manager.start_dialog_text("I'm gonna teach you the ultimate skill now", 4, "Squab", "left")
				6: 
					manual_command_letter(["n", "n"], true)
					_dialog_manager.enable_dialog_text(false)
					await get_tree().create_timer(2.5).timeout
					_progress_event()
				7: _dialog_manager.start_dialog_text("The ultimate skill - Word Steal!", 3, "Squab", "left")
				8: _dialog_manager.start_dialog_text("Steal Quabble's WIRE and form it into WINNER!", 3, "Squab", "left")
				9:  
					_dialog_manager.enable_dialog_text(false)
					toggle_highlight(0)
					attach_snatch_process()
				10: _dialog_manager.start_dialog_text("What the ^&*%. How dare you! Alright... its on!", 8, "Quabble", "right")
				11: _dialog_manager.start_dialog_text("Go on newbie and show her whose boss", 7, "Squab", "left")
				12: 
					_dialog_manager.enable_dialog_text(false)
					_Commander.start(Globals.GameMode.TUTORIAL, 1)
					set_snatch_function(true)
					_BoardMe.enable_reset(false)
					get_tree().call_group("lettertiles", "disable", false)
					get_tree().call_group("lettertiles", "force_disable", false)
				13: manual_transition_result_screen(true)
				14: _dialog_manager.start_dialog_text("Yes! Yes! You did it!", 3, "Squab", "left")
				15: _dialog_manager.start_dialog_text("Lucky shot newbie. Let's see how you fair without help", 1, "Quabble", "right")
				16: _dialog_manager.enable_dialog_text(false)
		7: #Second tutorial battle, no handholding except for special screen at the end
			match step:
				1: _static_dialog_manager.start_static_text("I'm playing for real now. Try not to lose")
				2: 
					_static_dialog_manager.enable_static_text(false)
					_Commander.start(Globals.GameMode.TUTORIAL, 1)
					set_snatch_function(true)
				3: manual_transition_result_screen(true)
				4:
					_dialog_manager.avatar2.texture = load("res://avatar/expression/Quabble8.png")
					_dialog_manager.anim_player.play("new_entrance_2")
					_dialog_manager.anim_player.seek(2.0, false)
					await get_tree().create_timer(0.01).timeout
					_dialog_manager.avatar1.texture = null
					_dialog_manager.start_dialog_text("Wow, Squab was right. You are different", 8, "Quabble", "right")
				5: _dialog_manager.start_dialog_text("I'm glad I could play against you", 5, "Quabble", "right")
				6: _dialog_manager.start_dialog_text("Now I'm HUNGRY! Could you feed me by watching an Ad... pls pls pls", 2, "Quabble", "right")
				7: 
					get_tree().root.get_node("Game/Pool/UI/WinLose").force_play_ad()
					_dialog_manager.start_dialog_text("Thank you so much!", 5, "Quabble", "right")
				8: _dialog_manager.start_dialog_text("You can get rid of Ads through the shop in the future", 4, "Quabble", "right")
				9: _dialog_manager.start_dialog_text("For now, lets continue our journey", 4, "Quabble", "right")
				10: _dialog_manager.enable_dialog_text(false)
		8: #First Encounter with Wallice, nothing special here except having dialogs at the end
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, false, "left", "res://avatar/expression/Quabble4.png", null)
			match step:
				1: _dialog_manager.start_dialog_text("Since you're so good, could you help me reclaim my crown?", 4, "Quabble", "left", true, init)
				2: _dialog_manager.start_dialog_text("Glad you said YES... not like you had an option *grin*", 6, "Quabble", "left", true)
				3: _dialog_manager.start_dialog_text("All I need is", 2, "Quabble", "left", true)
				4: 
					_dialog_manager.start_dialog_text("Quabble! I've not seen you since the BC days", 6, "Wallice", "right", false)
					_dialog_manager.anim_player.play("alt_entrance_2")
				5: _dialog_manager.start_dialog_text("Before Covid... BC... get it? Hahaha", 6, "Wallice", "right", true)
				6: _dialog_manager.start_dialog_text("Ugh... Wallice Wombat. Lame as ever", 1, "Quabble", "left", true)
				7: _dialog_manager.start_dialog_text("Where's your partner Squab? Ready for another beatdown?", 2, "Wallice", "right", true)
				8: _dialog_manager.start_dialog_text("I've got a new partner now. A much better one!", 3, "Quabble", "left", true)
				9: _dialog_manager.start_dialog_text("One who could easily beat you", 6, "Quabble", "left", true)
				10: _dialog_manager.start_dialog_text("Right. Remind me to beat you up once I've beat your partner down", 3, "Wallice", "right", true)
				11: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				12:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble6.png")
						_dialog_manager.start_dialog_text("You Cheated!", 1, "Wallice", "right", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble8.png")
						_dialog_manager.start_dialog_text("Did you say Much Better?", 6, "Wallice", "right", true)
				13:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Says the loser", 9, "Quabble", "left", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("I guess zero multiplied by zero is still ZERO! Hahaha", 6, "Wallice", "right", true)
				14:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Rematch!!!", 3, "Wallice", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Better luck next time losers", 6, "Wallice", "right", true)
				15:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		10: #Second Encounter with Wallice, guide players on booster use
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				manual_setter(["i","t","h","a","t","h","i"], [[0,1], [2,3,4], [5,6]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(true, true, "left", "res://avatar/expression/Quabble8.png", "res://avatar/expression/Wallice6.png")
			match step:
				1: _dialog_manager.start_dialog_text("What?! That's cheating", 8, "Quabble", "left", true, init)
				2: _dialog_manager.start_dialog_text("Says the loser to be", 6, "Wallice", "right", true)
				3: _dialog_manager.start_dialog_text("URGH! I was hoping to keep this for later.", 2, "Quabble", "left", true)
				4: _dialog_manager.start_dialog_text("Partner! Time to BOOST our powers.", 1, "Quabble", "left", true)
				5: 
					_dialog_manager.enable_dialog_text(false)
					manual_command_letter(["t"], true, 0)
					await get_tree().create_timer(1.0).timeout
					_progress_event()
				6: 
					_dialog_manager.start_dialog_text("Now use your Freeze Boost", 7, "Quabble", "left", true)
					$CanvasLayer/UI.show()
					$CanvasLayer/UI/Fake_Booster_Slot1.init(Globals.BoosterType.FREEZE, 1, true)
				7: _dialog_manager.enable_dialog_text(false)
				8: _dialog_manager.start_dialog_text("Freeze literally freeze your opponent so they cannot move until the effect wears off.", 6, "Quabble", "left", true)
				9: _dialog_manager.start_dialog_text("Now hit em hard. Form H I T", 6, "Quabble", "left", true)
				10: 
					toggle_highlight(5)
					_dialog_manager.enable_dialog_text(false)
					attach_snatch_process()
				11: 
					manual_command_letter(["w"], true, 0)
					await get_tree().create_timer(1.0).timeout
					_progress_event()
				12: _dialog_manager.start_dialog_text("WHAT?!", 3, "Wallice", "right", true)
				13: _dialog_manager.start_dialog_text("You said it. Form W H A T", 6, "Quabble", "left", true)
				14:
					toggle_highlight(8)
					_dialog_manager.enable_dialog_text(false)
					attach_snatch_process()
				15: _dialog_manager.start_dialog_text("You %^&^$*", 1, "Wallice", "right", true)
				16: _dialog_manager.start_dialog_text("You can use boosters once per level for now. ", 4, "Quabble", "left", true)
				17: _dialog_manager.start_dialog_text("I trust you can win this level easily", 5, "Quabble", "left", true)
				18: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
					_BoardOpponent.get_node("Tween").interpolate_property(_BoardOpponent.get_node("Background/Freeze_Effect"), "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR)
					_BoardOpponent.get_node("Tween").start()
		14: #Third Encounter with Wallice, nothing special here except pre-init tiles
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				manual_setter(["h","a","t","b","e","d","a","c","e"], [[0,1,2], [3,4,5], [6,7,8]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(true, true, "left", "res://avatar/expression/Quabble9.png", "res://avatar/expression/Wallice4.png")
			match step:
				1: _dialog_manager.start_dialog_text("Cheating more I see", 9, "Quabble", "left", true, init)
				2: _dialog_manager.start_dialog_text("...", 4, "Wallice", "right", true)
				3: _dialog_manager.start_dialog_text("Partner, Power Freeze is now available.", 2, "Quabble", "left", true)
				4: _dialog_manager.start_dialog_text("Use it to freeze Wallice longer when you see fit.", 3, "Quabble", "left", true)
				5: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		17: #Fourth Encounter with Wallice, more pre-initing tiles and result dialogs
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				manual_setter(["v","e","t","c","a","b","z","o","o"], [[0,1,2], [3,4,5], [6,7,8]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(true, true, "left", "res://avatar/expression/Quabble8.png", "res://avatar/expression/Wallice5.png")
			match step:
				1: _dialog_manager.start_dialog_text("I cannot lose here! Liona will kill me!", 5, "Wallice", "right", true, init)
				2: _dialog_manager.start_dialog_text("Careful partner. Wallice is desperate. He'll be harder to defeat.", 8, "Quabble", "left", true)
				3: _dialog_manager.start_dialog_text("I'm giving you 2 boosters. Freeze and Freeze+. Use wisely.", 2, "Quabble", "left", true)
				4: _dialog_manager.start_dialog_text("Good luck", 5, "Quabble", "left", true)
				5: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				6:
					if extra_params == "win":
						_dialog_manager.enable_dialog_text(true)
						_dialog_manager.start_dialog_text("This CANNOT BE!", 4, "Wallice", "right", true)
				7: _dialog_manager.start_dialog_text("Liona will have my head!", 4, "Wallice", "right", true)
				8: 
					_dialog_manager.anim_player.play("exit_2")
					_dialog_manager.start_dialog_text("Aaahhhhhh", 5, "Wallice", "right", false)
				9: _dialog_manager.start_dialog_text("Yeah, run off Woosy Wombat", 1, "Quabble", "left", true)
				10: _dialog_manager.start_dialog_text("Great job partner! ", 5, "Quabble", "left", true)
				11: _dialog_manager.start_dialog_text("What? Whose Liona? She's err... my cousin.", 3, "Quabble", "left", true)
				12: _dialog_manager.start_dialog_text("She's also Qing of the Jungle", 2, "Quabble", "left", true)
				13: _dialog_manager.start_dialog_text("And yes... I want you to beat her.", 6, "Quabble", "left", true)
				14: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					if !GameLoader.player_data["has_rated"]:
						$RatingLayer/Backdrop.show()
						GameLoader.player_data["has_rated"] = true
						pass
		18: # First Encounter with Killa
			if init:
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab2.png", "res://avatar/expression/Quabble9.png")
			match step:
				1: _dialog_manager.start_dialog_text("This is tiring... I'm gonna take a nap. Hey DOG. Stop lazying around. I'm tagging out", 9, "Quabble", "right", true, init)
				2: 
					_dialog_manager.anim_player.play("exit_2")
					_dialog_manager.start_dialog_text("*Grumble* Stupid cat...", 3, "Squab", "left", false)
				3: _dialog_manager.start_dialog_text("Well, partner... you did well to beat Wallice but he's a wuss", 9, "Squab", "left", true)
				4: _dialog_manager.start_dialog_text("We all know it. Your next opponent is not so kind.", 9, "Squab", "left", true)
				5:
					_dialog_manager.avatar2.texture = load("res://avatar/expression/Killa3.png")
					_dialog_manager.anim_player.play("alt_entrance_2")
					_dialog_manager.start_dialog_text("*Yaaaaaaawwwnnn*", 3, "Killa", "right", false)
				6: _dialog_manager.start_dialog_text("Wallice! How many times have I told you to...", 1, "Killa", "right", true)
				7: _dialog_manager.start_dialog_text("Squab? What are you doing here? Where's Wallice?", 3, "Killa", "right", true)
				8: _dialog_manager.start_dialog_text("We've beaten Wallice and now we're here to beat you Killa", 5, "Squab", "left", true)
				9: _dialog_manager.start_dialog_text("We? Quabble? Please... 0 + 0 is still ZERO", 5, "Killa", "right", true)
				10: _dialog_manager.start_dialog_text("Anyway, enough talk... be gone! ", 2, "Killa", "right", true)
				11:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		19:
			if init:
				manual_setter(["y","a","w","n","d","r","e","a","m"], [[0,1,2,3], [4,5,6,7,8]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(false, true, "right", null, "res://avatar/expression/Killa2.png")
			match step:
				1: _dialog_manager.start_dialog_text("I have underestimated your new partner.", 2, "Killa", "right", true, init)
				2: _dialog_manager.start_dialog_text("Not gonna happ... *Yaaaawwwwnnnn*", 3, "Killa", "right", true)
				3: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		20:
			if init:
				manual_setter(["w","a","k","e","u","p"], [[0,1,2,3], [4,5]])
				await get_tree().create_timer(1.0).timeout
				has_ended = true
				emit_signal("start_stage")
		21:
			if init:
				manual_setter(["u","p","n","o","w","w","a","k","e"], [[0,1], [2,3,4], [5,6,7,8]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab12.png", "res://avatar/expression/Killa3.png")
			match step:
				1: _dialog_manager.start_dialog_text("Ugh... Been sleeping way too long. This tree. This tree is so... Zzzz", 3, "Killa", "right", true, init)
				2: _dialog_manager.start_dialog_text("Partner, while Killa is still half asleep, we better beat him fast.", 12, "Squab", "left", true)
				3: _dialog_manager.start_dialog_text("You won't like him when he's fully awake.", 15, "Squab", "left", true)
				4: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		22:
			if init:
				manual_setter(["w","i","l","l","d","i","e","y","o","u"], [[0,1,2,3], [4,5,6], [7,8,9]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(false, true, "right", null, "res://avatar/expression/Killa2.png")
			match step:
				1: _dialog_manager.start_dialog_text("WAKE UP!!!!", 2, "Killa", "right", true, init)
				2: _dialog_manager.start_dialog_text("Hey you! Do me a favor and gimme a hand", 1, "Killa", "right", true, init)
				3:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		23:
			if init:
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab9.png", "res://avatar/expression/Killa5.png")
			match step:
				1: _dialog_manager.start_dialog_text("Finally!", 3, "Killa", "right", true, init)
				2: _dialog_manager.start_dialog_text("You... YOU!!!!", 1, "Killa", "right", true)
				3: _dialog_manager.start_dialog_text("HOW DARE YOU WAKE ME UP!!!", 1, "Killa", "right", true)
				4: _dialog_manager.start_dialog_text("Partner... we're in deep doodoo", 9, "Squab", "left", true)
				5: _dialog_manager.start_dialog_text("I hoped you packed some Freezers cause you're gonna need it.", 9, "Squab", "left", true)
				6: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		24:
			if init:
				manual_setter(["g","a","m","e","o","v","e","r"], [[0,1,2,3], [4,5,6,7]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(false, true, "right", null, "res://avatar/expression/Killa5.png")
			match step:
				1: _dialog_manager.start_dialog_text("Warm up is over. I hope you've got enough fun cause it ends now.", 5, "Killa", "right", true, init)
				2: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		25:
			if init:
				manual_setter(["a","m","s","e","r","i","o","u","s","n","o","w"], [[0,1], [2,3,4,5,6,7,8], [9,10,11]])
				await get_tree().create_timer(1.0).timeout
				has_ended = true
				emit_signal("start_stage")
		26:
			if init:
				manual_setter(["r","i","g","h","t","n","o","w","t","h","i","s","e","n","d","s"], [[0,1,2,3,4], [5,6,7], [8,9,10,11], [12,13,14,15]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab11.png", "res://avatar/expression/Killa2.png")
			match step:
				1: _dialog_manager.start_dialog_text("I'm impressed you made it this far", 2, "Killa", "right", true, init)
				2: _dialog_manager.start_dialog_text("I assure you this is it. No more.", 3, "Killa", "right", true)
				3: _dialog_manager.start_dialog_text("I think Wallice said the same thing...", 13, "Squab", "left", true)
				4: _dialog_manager.start_dialog_text("Partner, we can do this! Defeat this silly head.", 10, "Squab", "left", true)
				5: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		27:
			if init:
				manual_setter(["j","u","s","t","i","f","y","m","e","a","n","s","e","n","d"], [[0,1,2,3,4,5,6], [7,8,9,10,11], [12,13,14]])
				await get_tree().create_timer(1.0).timeout
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab2.png", "res://avatar/expression/Killa1.png")
			match step:
				1: _dialog_manager.start_dialog_text("What is this!", 1, "Killa", "right", true, init)
				2: _dialog_manager.start_dialog_text("You must be cheating! It's 2 versus 1. Its not fair! ", 1, "Killa", "right", true)
				3: _dialog_manager.start_dialog_text("Quit your yapping will ya, you sore loser", 7, "Squab", "left", true)
				4: _dialog_manager.start_dialog_text("Partner... I'm getting a very bad feeling. My doggy sense is tingling all over.", 8, "left", "right", true)
				5: 
					has_ended = false
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				6:
					if extra_params == "win":
						_dialog_manager.enable_dialog_text(true)
						_dialog_manager.start_dialog_text("So you beat me fair and square", 3, "Killa", "right", true)
				7: _dialog_manager.start_dialog_text("I admit, you're good", 2, "Killa", "right", true)
				8: _dialog_manager.start_dialog_text("But don't get prideful", 3, "Killa", "right", true)
				9: _dialog_manager.start_dialog_text("There is a saying that goes", 3, "Killa", "right", true)
				10: _dialog_manager.start_dialog_text("No matter how good a squirrel is, it still falls one day", 5, "Killa", "right", true)
				11: _dialog_manager.start_dialog_text("I think Killa is hinting something...", 9, "Squab", "left", true)
				12: _dialog_manager.start_dialog_text("Anyway, great job partner. I've never seen anyone win in such style!", 10, "Squab", "left", true)
				13: _dialog_manager.start_dialog_text("Future levels are coming soon", 11, "Squab", "left", true)
				14: _dialog_manager.start_dialog_text("In the meantime, try completing all the QUESTS!", 13, "Squab", "left", true)
				#13: _dialog_manager.start_dialog_text("On to the next battle ground!", 10, "Squab", "left", true)
				#14: _dialog_manager.start_dialog_text("to be continued...", 0, "", "none", true)		
				15: 
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		28:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, false, "left", "res://avatar/expression/Squab2.png", null)
			match step:
				1: 
					_dialog_manager.start_dialog_text("NUT so fast!", 5, "Quarrel", "right", false)
					_dialog_manager.anim_player.play("alt_entrance_2")
				2: _dialog_manager.start_dialog_text("Uh oh", 8, "Squab", "left", true)
				3: _dialog_manager.start_dialog_text("Tsk tsk... What do we have here... Good ol’ Squab & Quabble, and this is?", 2, "Quarrel", "right", true)
				4: _dialog_manager.start_dialog_text("Quarrel Squirrel, meet your new opponent!", 6, "Squab", "left", true)
				5: _dialog_manager.start_dialog_text("Hah! This newbie WALNUT win!", 5, "Quarrel", "right", true)
				6: _dialog_manager.start_dialog_text("We’ll see!", 3, "Squab", "left", true)
				7: _dialog_manager.start_dialog_text("Watch out, buddy. Some tiles may appear upside down!", 11, "Squab", "left", true)
				8: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				9:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble3.png")
						_dialog_manager.start_dialog_text("Tsschkkk! This isn’t over!", 1, "Quarrel", "right", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble8.png")
						_dialog_manager.start_dialog_text("HAHA! You’re no match for me! Are you even trying?", 5, "Quarrel", "right", true)
				10:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("you mean, it’s NUT over?", 6, "Quabble", "left", true)
					if extra_params == "lose":
						has_ended = true
						_dialog_manager.enable_dialog_text(false)
				11:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Enough! The real battle starts now!", 1, "Quarrel", "right", true)
				12:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		30:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, false, "left", "res://avatar/expression/Squab11.png", null)
			match step:
				1: _dialog_manager.start_dialog_text("Hey buddy, here's a new Blast Booster for you.", 11, "Squab", "left", true, init)
				2: _dialog_manager.start_dialog_text("It destroys 3 letter words your opponent has formed.", 10, "Squab", "left", true)
				3: _dialog_manager.start_dialog_text("Go on, try it out!", 12, "Squab", "left", true)
				4:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		31:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab2.png", "res://avatar/expression/Quarrel1.png")
			match step:
				1: _dialog_manager.start_dialog_text("Hurry up, newbie! I have better things to do than to fight you.", 1, "Quarrel", "right", true, init)
				2: _dialog_manager.start_dialog_text("Uh... so why are you here then?", 13, "Squab", "left", true)
				3: _dialog_manager.start_dialog_text("(shocked) I-I... It’s none of your squirrel business!!", 2, "Quarrel", "right", false)
				4: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				5:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar2.texture = load("res://avatar/expression/Quarrel1.png")
						_dialog_manager.start_dialog_text("Now that we’ve won, you better spill the beans! ", 7, "Squab", "left", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Squab8.png")
						_dialog_manager.start_dialog_text("Hmph! Better luck next time, newbie!", 5, "Quarrel", "right", true)
				6:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Pfft! Over my fluffy tail!", 3, "Quarrel", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Come on, partner! I know you can do this!", 9, "Squab", "left", true)
				7:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Watch out, a squirrel with a puffed up tail is an angry one.", 8, "Squab", "left", true)
					if extra_params == "lose":
						has_ended = true
						_dialog_manager.enable_dialog_text(false)
				8:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		34:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Quabble9.png", "res://avatar/expression/Quarrel1.png")
			match step:
				1: _dialog_manager.start_dialog_text("Alright, you want to know why I’m here?", 1, "Quarrel", "right", true, init)
				2: _dialog_manager.start_dialog_text("Let me guess, Liona has got you under her claw?", 2, "Quabble", "left", true)
				3: _dialog_manager.start_dialog_text("It’s not like I have a choice. I have to win or she’ll turn me into Squirrel Stew!", 4, "Quarrel", "right", true)
				4: _dialog_manager.start_dialog_text("Yikes...?", 3, "Quabble", "left", true)
				5: _dialog_manager.start_dialog_text("That's why, I MUST WIN.", 3, "Quarrel", "right", true)
				6: _dialog_manager.start_dialog_text("Alright, partner. Time to BLAST this squirrel away!", 1, "Quabble", "left", true)
				7:
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				8:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar2.texture = load("res://avatar/expression/Quarrel1.png")
						_dialog_manager.start_dialog_text("Good job, partner! ", 13, "Squab", "left", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Squab8.png")
						_dialog_manager.start_dialog_text("Tsskk! You can't beat me!", 5, "Quarrel", "right", true)
				9:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Hah! Not quite!", 1, "Quarrel", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Oh yeah, watch us!", 3, "Squab", "left", true)
				10:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Uh oh...", 11, "Squab", "right", true)
					if extra_params == "lose":
						has_ended = true
						_dialog_manager.enable_dialog_text(false)
				11:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		36:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(false, true, "right", null, "res://avatar/expression/Quarrel1.png")
			match step:
				1: _dialog_manager.start_dialog_text("I pick letters like picking acorns, you have nuttin’ on me!", 1, "Quarrel", "right", true, init)
				2:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		37:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, true, "left", "res://avatar/expression/Squab11.png", "res://avatar/expression/Quarrel3.png")
			match step:
				1: _dialog_manager.start_dialog_text("This is it, partner. The final battle!", 11, "Squab", "left", true, init)
				2: _dialog_manager.start_dialog_text("Tssk! This is peanuts!", 3, "Quarrel", "right", true)
				3: _dialog_manager.start_dialog_text("Better load up your Boosters now!", 12, "Squab", "left", true)
				4:
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				5:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble3.png")
						_dialog_manager.start_dialog_text("Nooooo!!!", 4, "Quarrel", "right", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble8.png")
						_dialog_manager.start_dialog_text("Yes, yes, YESSSS! No more Squirrel Stew!", 5, "Quarrel", "right", true)
				6:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Liona will have me for supper!", 4, "Quarrel", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("No way! Rematch! Now!", 8, "Quabble", "left", true)
				7:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Not if we defeat her!", 2, "Quabble", "left", true)
					if extra_params == "lose":
						has_ended = true
						_dialog_manager.enable_dialog_text(false)
				8:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("It’s not that easy...", 4, "Quarrel", "right", true)
				9:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Pfft! What are we? Newbies?", 1, "Quabble", "left", true)
				10:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("When I get Liona’s throne, I’ll make sure you’re safe.", 2, "Quabble", "left", true)
				11:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Before I go, I must warn you… Your next opponent is not so... reasonable.", 2, "Quarrel", "right", true)
				12:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Alright, alright... Cashew later, we have a throne to snatch!", 5, "Quabble", "left", true)
				13:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		38:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, false, "left", "res://avatar/expression/Squab2.png", null)
			match step:
				1: 
					_dialog_manager.start_dialog_text("Oook! Look who’s come to play?!", 5, "Moniac", "right", false)
					_dialog_manager.anim_player.play("alt_entrance_2")
				2: _dialog_manager.start_dialog_text("Oh no, that’s Moniac the Monkey. She’s kind of bananas...", 8, "Squab", "left", true)
				3: _dialog_manager.start_dialog_text("Ooh! Aaak! What you did back there was elementary at best.", 2, "Moniac", "right", true)
				4: _dialog_manager.start_dialog_text("This is a whole new level, ehehehe!!", 5, "Moniac", "right", true)
				5: _dialog_manager.start_dialog_text("See? Told ya.", 6, "Squab", "left", true)
				6: _dialog_manager.start_dialog_text("Quit yapping, this fight’s not gonna win itself!", 3, "Moniac", "right", true)
				7: _dialog_manager.start_dialog_text("Grrr! You heard the monkey, let’s go!", 3, "Squab", "left", true)
				8: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				9:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar2.texture = load("res://avatar/expression/Moniac1.png")
						_dialog_manager.start_dialog_text("Now that’s how you do it!", 14, "Squab", "left", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Squab11.png")
						_dialog_manager.start_dialog_text("Ehehehe!! Is that all you’ve got? ", 5, "Moniac", "right", true)
				10:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Eeek! Moniac is just getting started!", 1, "Moniac", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Hmph! We’ll get into the swing of things in no time!", 11, "Squab", "left", true)
				11:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		41:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, true, "left", "res://avatar/expression/Quabble9.png", "res://avatar/expression/Squab2.png")
			match step:
				1: _dialog_manager.start_dialog_text("I still can’t believe Liona got you to play guard dog.", 9, "Quabble", "left", true, init)
				2: _dialog_manager.start_dialog_text("Hey! Watch it, buddy.", 3, "Squab", "right", true)
				3: _dialog_manager.start_dialog_text("I’m talking about Moniac!", 8, "Quabble", "left", true)
				4: 
					_dialog_manager.avatar1.texture = null
					_dialog_manager.avatar2.texture = null
					_dialog_manager.start_dialog_text("Ook! Our friends are having a squabble!", 5, "Moniac", "right", true)
				5: _dialog_manager.start_dialog_text("You’re not even the loyal type!", 1, "Squab", "left", true)
				6: _dialog_manager.start_dialog_text("Eeek!! Moniac is only loyal to her whimsies and Liona lets this monkey have her way with losers!", 3, "Moniac", "right", true)
				7: _dialog_manager.start_dialog_text("Whatever it is, I don’t want to find out.", 8, "Quabble", "left", true)
				8: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				9:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar2.texture = load("res://avatar/expression/Moniac4.png")
						_dialog_manager.start_dialog_text("Good job, partner! I know I can count on you!", 14, "Squab", "left", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Squab8.png")
						_dialog_manager.avatar2.texture = load("res://avatar/expression/Quabble8.png")
						_dialog_manager.start_dialog_text("Oh come on, I’m sure you can do better?", 8, "Quabble", "right", true)
				10:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("Moniac has more games for you, ehehe!", 4, "Moniac", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Quabble! Not with this attitude...", 9, "Squab", "left", true)
				11:
					if extra_params == "win":
						has_ended = true
						_dialog_manager.enable_dialog_text(false)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Alright... Come on, buddy. Let’s try again.", 1, "Quabble", "right", true)
				12:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		44:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(false, true, "right", null, "res://avatar/expression/Moniac5.png")
			match step:
				1: _dialog_manager.start_dialog_text("Moniac just can't get enough of this monkey business, eek!", 5, "Moniac", "right", true, init)
				2:
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		47:
			if init:
				Audio.play_music(Audio.Music.MUSIC_HOME)
				_dialog_manager.setup_dialog(true, true, "right", "res://avatar/expression/Squab14.png", "res://avatar/expression/Moniac3.png")
			match step:
				1: _dialog_manager.start_dialog_text("Eehehehe!!!! You think you’ve seen it all?", 3, "Moniac", "right", true, init)
				2: _dialog_manager.start_dialog_text("You’re not ready for the whole circus!", 2, "Moniac", "right", true)
				3: _dialog_manager.start_dialog_text("YOU’RE NOT READYYYYYY!!!!!!", 1, "Moniac", "right", true)
				4: _dialog_manager.start_dialog_text("Moniac has finally lost the plot!", 13, "Squab", "left", true)
				5: _dialog_manager.start_dialog_text("We must stop her before it’s too late!", 11, "Squab", "left", true)
				6: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				7:
					_dialog_manager.enable_dialog_text(true)
					if extra_params == "win":
						_dialog_manager.avatar2.texture = load("res://avatar/expression/Moniac4.png")
						_dialog_manager.start_dialog_text("Victory!! Hmm, tastes better than banana split!", 2, "Squab", "left", true)
					if extra_params == "lose":
						_dialog_manager.avatar1.texture = load("res://avatar/expression/Quabble8.png")
						_dialog_manager.start_dialog_text("Yessss! You’re now Moniac’s new toys!", 5, "Moniac", "right", true)
				8:
					if extra_params == "win":
						_dialog_manager.start_dialog_text("EEEK! This is NOT the last of Moniac, you’ll see!", 4, "Moniac", "right", true)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Ook, what shall Moniac do with you?", 5, "Moniac", "right", true)
				9:
					if extra_params == "win":
						has_ended = true
						_dialog_manager.enable_dialog_text(false)
					if extra_params == "lose":
						_dialog_manager.start_dialog_text("Hurry, we mustn’t let her win! We can still try!", 1, "Quabble", "left", true)
				10:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
		108:
			if init: 
				_dialog_manager.setup_dialog(true, false, "left", "res://avatar/expression/Quabble6.png", "res://avatar/expression/Liona5.png")
			match step:
				1: _dialog_manager.start_dialog_text("Partner. We are finally HERE!!!", 6, "Quabble", "left", true, init)
				2: 
					_dialog_manager.start_dialog_text("Well look at what just came.", 5, "Liona", "right", false)
					_dialog_manager.anim_player.play("alt_entrance_2")
				3: _dialog_manager.start_dialog_text("Its been a long time Quibby", 5, "Liona", "right", true)
				4: _dialog_manager.start_dialog_text("Its Quabble!", 1, "Quabble", "left", true)
				5: _dialog_manager.start_dialog_text("I'm here for my throne", 1, "Quabble", "left", true)
				6: _dialog_manager.start_dialog_text("Your throne? You can't even spell throne.", 5, "Liona", "right", true)
				7: _dialog_manager.start_dialog_text("You keep talking Liona. My partner here will show you whose boss.", 8, "Quabble", "left", true)
				8: _dialog_manager.start_dialog_text("Ooo... I'm so scared", 4, "Liona", "right", true)
				9: _dialog_manager.start_dialog_text("Let's get this over with. I'm busy", 2, "Liona", "right", true)
				10:
					has_ended = true
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
		118:
			if init: 
				_dialog_manager.setup_dialog(true, true, "left", "res://avatar/expression/Quabble6.png", "res://avatar/expression/Liona1.png")
			match step:
				1: _dialog_manager.start_dialog_text("Woohoo!!! Partner you are on a roll", 6, "Quabble", "left", true, init)
				2: _dialog_manager.start_dialog_text("ARGH!!! THIS.... IS.... SOOOOO... ANNOYING.", 1, "Liona", "right", true)
				3: _dialog_manager.start_dialog_text("THAT'S IT! It ends NOW!", 1, "Liona", "right", true)
				4: _dialog_manager.start_dialog_text("Alright Partner... one last win! Let's go!!!", 5, "Quabble", "left", true)
				5: 
					_dialog_manager.enable_dialog_text(false)
					emit_signal("start_stage")
				6: 
					if extra_params == "win":
						_dialog_manager.enable_dialog_text(true)
						_dialog_manager.start_dialog_text("WHAT IS THIS MADNESS?!", 1, "Liona", "right", true)
				7: _dialog_manager.start_dialog_text("HOW IS THIS POSSIBLE!", 1, "Liona", "right", true)
				8: _dialog_manager.start_dialog_text("Oh yes it is Lizzy", 5, "Quabble", "left", true)
				9: _dialog_manager.start_dialog_text("You LOST! Gimme back my throne", 3, "Quabble", "left", true)
				10: _dialog_manager.start_dialog_text("But... but...", 4, "Liona", "right", true)
				11: _dialog_manager.start_dialog_text("Yeah... turn your butt and GET OUT!", 8, "Quabble", "left", true)
				12: _dialog_manager.start_dialog_text("his is not the end Quabble. You will regret this", 3, "Liona", "right", true)
				13: _dialog_manager.start_dialog_text("WHATEVER", 9, "Quabble", "left", true)
				14: _dialog_manager.start_dialog_text("Now GO!", 1, "Quabble", "left", true)
				15: _dialog_manager.start_dialog_text("Partner. We did it. YOU did it. It was hard but well worth it.", 5, "Quabble", "left", true)
				16: _dialog_manager.start_dialog_text("Now for some much needed rest. Great work again... Partner", 7, "Quabble", "left", true)
				17: #roll credits?
					roll_credits_temp()
					has_ended = true
					_dialog_manager.enable_dialog_text(false)


func roll_credits_temp() -> void:
	$CreditLayer/Panel.show()
	$Tween.interpolate_property($CreditLayer/Panel, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR)
	$Tween.interpolate_property($CreditLayer/Panel/Label, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	$Tween.interpolate_property($CreditLayer/Panel/RichTextLabel, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.75)
	$Tween.interpolate_property($CreditLayer/Panel/Label2, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.0)
	$Tween.interpolate_property($CreditLayer/Panel/TextureRect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.25)
	$Tween.start()


func _progress_event() -> void:
	step += 1
	initiate_event(this_level, step)


func _progress_event_alt(param1, param2, param3, param4, param5, param6) -> void:
	step += 1
	initiate_event(this_level, step)
	_BoardMe.disconnect("letters_snatched", Callable(self, "_progress_event_alt"))


func attach_snatch_process() -> void:
	_BoardMe.show_snatch_button(true)
	_BoardMe.connect("letters_snatched", Callable(self, "_progress_event_alt"))


func _on_letter_picked(id: int, is_picked: bool) -> void:
	if !levels_with_events.has(this_level):
		return
	
	var letter: Letter = WordList.spawned_letters[id]["node"]
	var formed_letters = ""
	if not is_picked:
		_picked_letters.erase(letter)
	else:
		_picked_letters.append(letter)
	
	for letters in _picked_letters:
		formed_letters += letters.letter
		
	match this_level: 
		1:
			var final_word_1: String = "well"
			var final_word_2: String = "done"
			var check_string_1: String = final_word_1.substr(0, formed_letters.length())
			var check_string_2: String = final_word_2.substr(0, formed_letters.length())
			var order_of_selection_1: Array = [1,2,3,100]
			var order_of_selection_2: Array = [5,6,7,100]
			match step:
				5: check_condition_to_pick(formed_letters, check_string_1, true, false, false, order_of_selection_1[formed_letters.length() - 1])
				6: check_condition_to_pick(formed_letters, check_string_1, true, false, false, order_of_selection_1[formed_letters.length() - 1])
				7: check_condition_to_pick(formed_letters, check_string_1, true, false, false, order_of_selection_1[formed_letters.length() - 1])
				8: check_condition_to_pick(formed_letters, check_string_1, true, true, false, order_of_selection_1[formed_letters.length() - 1])
				12: check_condition_to_pick(formed_letters, check_string_2, true, false, false, order_of_selection_2[formed_letters.length() - 1])
				13: check_condition_to_pick(formed_letters, check_string_2, true, false, false, order_of_selection_2[formed_letters.length() - 1])
				14: check_condition_to_pick(formed_letters, check_string_2, true, false, false, order_of_selection_2[formed_letters.length() - 1])
				15: check_condition_to_pick(formed_letters, check_string_2, true, false, true, order_of_selection_2[formed_letters.length() - 1])
		3:
			match step:
				2: 
					var final_word: String = "me"
					var check_string: String = final_word.substr(0, formed_letters.length())
					var order_of_selection: Array = [1, 100]
					check_condition_to_pick(formed_letters, check_string, false, true, true, order_of_selection[formed_letters.length() - 1])
				3: 
					var final_word: String = "come"
					var check_string: String = final_word.substr(0, formed_letters.length())
					var order_of_selection: Array = [3,0,1,100]
					check_condition_to_pick(formed_letters, check_string, false, true, true, order_of_selection[formed_letters.length() - 1])
				6: 
					var final_word: String = "welcome"
					var check_string: String = final_word.substr(0, formed_letters.length())
					var order_of_selection: Array = [5,6,2,3,0,1,100]
					check_condition_to_pick(formed_letters, check_string, false, true, true, order_of_selection[formed_letters.length() - 1])
		6:
			match step:
				9:
					var final_word: String = "winner"
					var check_string: String = final_word.substr(0, formed_letters.length())
					var order_of_selection: Array = [1,4,5,3,2,100]
					check_condition_to_pick(formed_letters, check_string, false, true, true, order_of_selection[formed_letters.length() - 1])
		10: 
			match step:
				10: 
					var final_word: String = "hit"
					var check_string: String = final_word.substr(0, formed_letters.length())
					var order_of_selection: Array = [6,7,100]
					check_condition_to_pick(formed_letters, check_string, false, true, true, order_of_selection[formed_letters.length() - 1])
				14: 
					var final_word: String = "what"
					var check_string: String = final_word.substr(0, formed_letters.length())
					var order_of_selection: Array = [2,3,4,100]
					check_condition_to_pick(formed_letters, check_string, false, true, true, order_of_selection[formed_letters.length() - 1])


func toggle_highlight(this_letter: int = -1) -> void:
	get_tree().call_group("lettertiles", "disable")
	await get_tree().create_timer(0.1).timeout
	while(WordList.get_if_letter_exists(this_letter) == false):
		await get_tree().create_timer(0.1).timeout
	WordList.get_spawned_letter_data(this_letter)["node"].disable(false)
	WordList.get_spawned_letter_data(this_letter)["node"].get_node("AnimTap").play("highlight")


func check_condition_to_pick(current_word, target_word, progress = false, snatch = false, swipe = false, manual_enable: int = -1) -> bool:
	if current_word == target_word:
		while WordList.get_spawned_letter_data(manual_enable).has("node"):
			WordList.get_spawned_letter_data(manual_enable)["node"].disable(false)
			WordList.get_spawned_letter_data(manual_enable)["node"].get_node("AnimTap").play("highlight")
			break
		
		get_tree().call_group("lettertiles", "disable")
		get_tree().call_group("lettertiles", "force_disable")
		
		if progress:
			print("azri progress 1")
			_progress_event()
		
		set_snatch_function(false)
		if manual_enable == 100:
			_BoardMe.enable_snatch_button(true) if snatch else _BoardMe.enable_snatch_button(false)
			_BoardMe.enable_snatch_swipe(true) if swipe else _BoardMe.enable_snatch_swipe(false)
			_BoardMe.enable_reset(false)
			_picked_letters.clear()
		elif manual_enable != -1:
			toggle_highlight(manual_enable)
		
		return true
	else:
		return false


func manual_command_letter(this_letters: Array, disabled: bool = false, override_interval_timer: float = 1.0) -> void:
	for g in this_letters:
		var interval: float = 1
		get_tree().root.get_node("Game/Commander").command(["s", "l" if randi() % 10 > 5 else "r", { "impulse": 700, "rotation_degrees": 0, "disabled": disabled }, [g], override_interval_timer])


func manual_setter(letterlist: Array, wordlist: Array) -> void:
	var _spawned_letter_index: int = 0
	var _this_word: Array = letterlist
	
	var _init_words: Array = wordlist
	
	var generate_positions = []
	var spacing = 0
	var row = 0
	
	#92 for x separation, 120 for y separation
	#612 for y position
	for words in _init_words:
		var precheck_spacing = spacing + words.size()
		if precheck_spacing > 10:
			spacing = 0
			row += 1
		for letters in words:
			generate_positions.append([63 + (92 * spacing), 612 - (row * 120)])
			spacing += 1
		spacing += 1
	
	for i in _this_word.size():
		var letter: Letter = _ScnLetter.instantiate()
		letter.init(
		_spawned_letter_index,
		_this_word[i],
		WordList.get_letter_points(_this_word[i]),
		Globals.LetterOwnership.POOL
	)
		Letter.position = Vector2(generate_positions[i][0], generate_positions[i][1])
		letter.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
		letter.set_freeze_enabled(true)
		letter._skip_interpolate = true
		_spawned_letter_index += 1
		get_parent().get_node("Spawner")._spawned_letter_index += 1
		get_parent().add_child(letter)
		get_parent()._on_Spawner_letter_spawned(Letter)
	
	await get_tree().create_timer(0.01).timeout
	for i in _init_words.size():
		get_tree().root.get_node("Game/Commander").command(["m", Globals.LetterOwnership.POOL, Globals.LetterOwnership.BOARD_OPPONENT, _init_words[i], 0, true])
	get_tree().call_group("lettertiles", "disable")
	get_tree().call_group("lettertiles", "force_disable")


func manual_transition_result_screen(extra_parts: bool = false) -> void:
	_dialog_manager.enable_dialog_text(false)
	_static_dialog_manager.enable_static_text(false)
	_Commander.stop()
	
	if GameLoader.player_data["level_progression"][str(this_level)]["completion"] != 2:
		get_tree().root.get_node("Game/Pool/UI/WinLose").on_custom_result_announced(100, 5)
	else:
		get_tree().root.get_node("Game/Pool/UI/WinLose").on_custom_result_announced(0, 0)
		
	if this_level == 7:
		GameLoader.player_data["completed_tutorial"] = true
	GameLoader.set_level_progression_data(this_level, 3)
	
	has_ended = extra_parts
	if extra_parts:
		await get_tree().create_timer(3.5).timeout
		Audio.play_music(Audio.Music.MUSIC_HOME)
		_progress_event()


func set_snatch_function(enable: bool) -> void:
	_BoardMe.enable_snatch_button(enable)
	_BoardMe.enable_snatch_swipe(enable)
	_BoardMe.enable_reset(enable)


func set_custom_avatar_expression(character: String,expression: String) -> void:
	match character:
		"Squab": _BoardOpponent.get_node("Avatar").set_avatar(load("res://tutorial/textures/tutorial_" + expression + ".png"), Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_OPPONENT])
		"Squab_Drink": _BoardOpponent.get_node("Avatar").set_avatar(load("res://tutorial/textures/tutorial_profile_drinktea_" + expression + ".png"), Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_OPPONENT])
		"Squab_Drink_Norm":_BoardOpponent.get_node("Avatar").set_avatar(load("res://tutorial/textures/tutorial_profile_drinktea.png"), Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_OPPONENT])
	pass


func set_cursor(show: bool) -> void:
	var cursor = $CanvasLayer/Cursor
	if show:
		cursor.show()
		$Tween.interpolate_property(cursor, "position", cursor.position, cursor.position + (Vector2.DOWN * 600), 2.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$Tween.start()
	else:
		cursor.hide()
		$Tween.stop_all()


func set_overlay(overlay_type) -> void:
	$CanvasLayer/Overlay.set_texture(overlay_type)
	$CanvasLayer/Overlay.show()


func reset_fake_boosters() -> void:
	$CanvasLayer/UI.hide()
	for i in range(1,5):
		get_node("CanvasLayer/UI/Fake_Booster_Slot" + str(i)).reset_booster()


func fake_booster_callback(_booster_set: int, _booster_level: int) -> void:
	if this_level == 10:
		_BoardOpponent.get_node("Tween").interpolate_property(_BoardOpponent.get_node("Background/Freeze_Effect"), "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.15, Tween.TRANS_LINEAR)
		_BoardOpponent.get_node("Tween").start()
	
	_progress_event()


func _on_Btn_OpenRate_pressed():
	$RatingLayer/Backdrop.hide()


func _on_Btn_CloseRate_pressed():
	$RatingLayer/Backdrop.hide()
