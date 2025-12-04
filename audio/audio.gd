extends Node2D

enum Music { MUSIC_HOME, MUSIC_LOOKING_FOR_OPPONENT, MUSIC_OPPONENT_FOUND, MUSIC_WIN, MUSIC_LOSE, MUSIC_PLAY, MUSIC_PLAY_2 }
enum Sfx { BUTTON_TAP, LETTER_SELECTED, WORD_SUCCESS, WORD_FAIL }

var _current_music: AudioStreamPlayer
var _current_sfx: AudioStreamPlayer

var _last_played_music: int = 0
var _is_muted_music: bool = false
var _is_muted_sfx: bool = false


func play_music(what, from_position: float = 0.0) -> void:
	_last_played_music = what
	stop_music()
	
	match what:
		Music.MUSIC_HOME: _current_music = $MusicHome
		Music.MUSIC_LOOKING_FOR_OPPONENT: _current_music = $MusicLookingForOpponent
		Music.MUSIC_OPPONENT_FOUND: _current_music = $MusicOpponentFound
		Music.MUSIC_WIN: _current_music = $MusicWin
		Music.MUSIC_LOSE: _current_music = $MusicLose
			
		Music.MUSIC_PLAY:
			_current_music = $MusicPlay
			if not $MusicPlay.is_connected("finished", Callable($MusicPlay, "finished")):
				# warning-ignore:return_value_discarded
				$MusicPlay.connect("finished", Callable($MusicPlay, "finished"))
		
		Music.MUSIC_PLAY_2:
			_current_music = $MusicPlay2
			if not $MusicPlay2.is_connected("finished", Callable($MusicPlay2, "finished")):
				# warning-ignore:return_value_discarded
				$MusicPlay2.connect("finished", Callable($MusicPlay2, "finished"))
			
	_current_music.play(from_position)
	if _is_muted_music:
		_current_music.volume_db = -80
	else:
		_current_music.volume_db = 0


func play_random_play_music() -> void:
	var music: Array = [
		Music.MUSIC_PLAY,
		Music.MUSIC_PLAY_2
	]
	randomize()
	var r: int = music[randi() % music.size()]
	play_music(r)


func stop_music() -> void:
	if _current_music and _current_music.playing:
		if _current_music.is_connected("finished", Callable(_current_music, "finished")):
			_current_music.disconnect("finished", Callable(_current_music, "finished"))
		_current_music.stop()
		$MusicPlay.reset()
		$MusicPlay2.reset()
		
		
func stop_and_mute_music(is_muted: bool = true) -> void:
	set_mute_music(is_muted)
	if is_muted:
		stop_music()
	else:
		play_music(_last_played_music)


func play_sfx(what, from_position: float = 0.0) -> void:
	if not _is_muted_sfx:
		match what:
			Sfx.BUTTON_TAP: $SfxTap.play(from_position)		
			Sfx.LETTER_SELECTED: $SfxLetter.play(from_position)		
			Sfx.WORD_SUCCESS: $SfxWord.play(from_position)			
			Sfx.WORD_FAIL: $SfxWordFail.play(from_position)


func set_mute_music(is_muted: bool = true) -> void:
	_is_muted_music = is_muted
	if _is_muted_music and _current_music != null:
		_current_music.volume_db = -80
	elif !_is_muted_music and _current_music != null:
		_current_music.volume_db = 0


func set_mute_sfx(is_muted: bool = true) -> void:
	_is_muted_sfx = is_muted
