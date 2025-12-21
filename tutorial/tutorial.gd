extends Node2D

signal name_changed

var _Pool: Node2D = null
var _Commander: Node2D = null
var _BoardMe: Board = null
var _BoardOpponent: Board = null


var score_requirement: Array = [0,0,15,0,25,30,30,30]
var current: Array = ["", "tutorial", "sandbox", "tutorial", "sandbox", "sandbox", "gameplay", "gameplay"]

var tutorial_part: int = 1
var replay_level: bool = false


func _ready() -> void:
	stop()


func start_gameplay_layer(pool: Node2D, commander: Node2D, board_me: Board, board_opponent: Board) -> void:
	show()
	$CanvasModulate.hide()
	
	if has_node("IntroLayer"):
		$IntroLayer.follow_viewport_scale = 0
		$IntroLayer/IntroUI/AnimTutorialUI.stop(true)
		$IntroLayer.queue_free()
	
	_Pool = pool
	_Commander = commander
	_BoardMe = board_me
	_BoardOpponent = board_opponent
	
	board_me._score_target = score_requirement[tutorial_part]
	board_me.enable_reset(false)
	
	# Replace ternary with normal if/else
	if tutorial_part > 1:
		board_me.show_score_panel(true)
	else:
		board_me.show_score_panel(false)
	
	board_me.enable_snatch_button(false)
	board_me.enable_snatch_swipe(false)
	
	_BoardMe.set_avatar(Globals.AvatarTextures[Globals.AvatarCharacter.DEFAULT], Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_ME])
	
	if tutorial_part < 6:
		Audio.play_music(Audio.Music.MUSIC_HOME)
		board_opponent.set_opponent_name("Squab")  # renamed from set_name to avoid GD4 conflict
		board_opponent.set_avatar(Globals.AvatarTextures[Globals.AvatarCharacter.DOG], Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_ME])
		board_opponent.get_node("Avatar/Tutorial_Backdrop").show()
		board_opponent.show_score_panel(false)
	else:
		Audio.play_music(Audio.Music.MUSIC_PLAY_2)
		board_opponent.set_opponent_name("Quabble")  # renamed method
		board_opponent.set_avatar(Globals.AvatarTextures[Globals.AvatarCharacter.CAT], Globals.AvatarBackgroundTextures[Globals.LetterOwnership.BOARD_OPPONENT])
		board_opponent.get_node("Avatar/Tutorial_Backdrop").hide()
		board_opponent.show_score_panel(true)
	
	# Replace ternary hide/show
	if tutorial_part < 6:
		pool.get_node("Level").hide()
	else:
		pool.get_node("Level").show()
	
	if tutorial_part < 4:
		pool.get_node("TilesCounter").hide()
	else:
		pool.get_node("TilesCounter").show()
	
	if score_requirement[tutorial_part] != 0:
		board_me.enable_reset(true)
	
	match tutorial_part:
		5: 
			var dialog_manager = pool.get_node("EventManager/DialogLayer/DialogManager")
			dialog_manager.avatar1.rect_position = Vector2(-1240, 880)
			dialog_manager.avatar2.rect_position = Vector2(1240, 880)
		6, 7:
			board_opponent.show_info()
			board_opponent._score_target = score_requirement[tutorial_part]
			if tutorial_part == 6:
				board_me.enable_reset(false)



func stop() -> void:
	hide()
	if not visible:
		if get_node_or_null("IntroLayer"):
			$IntroLayer/IntroUI.hide()
			$IntroLayer/IntroUI/AnimTutorialUI.stop(true)


func letters_snatched(from_who: int, longest_word: String, picked_letters: Array) -> void:
	if visible:
		if current[tutorial_part] != "tutorial":
			await get_tree().create_timer(1.0).timeout
			if _BoardMe._score_next >= score_requirement[tutorial_part]:
				_BoardMe.enable_snatch_button(false)
				_BoardMe.enable_snatch_swipe(false)
				print("azri progress event 3")
				_Pool.get_node("EventManager")._progress_event()
		else:
			_BoardMe.enable_snatch_button(false)
			_BoardMe.enable_snatch_swipe(false)
			print("azri prgress event 4")
			_Pool.get_node("EventManager")._progress_event()



func start_intro(force_start: bool = false) -> void:
	if force_start:
		show()
		if get_node_or_null("IntroLayer"):
			$CanvasModulate.show()
			$IntroLayer.follow_viewport_scale = 1
			$IntroLayer/IntroUI/AnimTutorialUI.stop(true)
			$IntroLayer/IntroUI/AnimTutorialUI.play("intro")
			$IntroLayer/IntroUI.show()
	else:
		hide()
		$CanvasModulate.hide()


func _on_IntroLayer_pool_started(mode: int):
	$CanvasModulate.hide()


func _on_IntroLayer_name_changed(name: String) -> void:
	emit_signal("name_changed", name)
