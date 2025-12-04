extends Timer

signal game_over
signal result_announced

var _mode: int = 0

var _points: Dictionary = {}
var _longest_words: Dictionary = {}
var _best_words: Dictionary = {}

func set_mode(mode: int) -> void:
	_mode = mode
	set_longest_words({})
	set_best_words({})
	set_points({})


func set_points(points: Dictionary) -> void:
	_points = points


func set_longest_words(longest_words: Dictionary) -> void:
	_longest_words = longest_words


func set_best_words(best_words: Dictionary) -> void:
	_best_words = best_words


func _on_GameOverTimer_timeout():	
	emit_signal("game_over")
	
	get_tree().call_group("lettertiles", "deselect")
	get_tree().call_group("lettertiles", "depress")
	get_tree().call_group("lettertiles", "disable")
	get_tree().call_group("boards", "clear_picked_letters")	
	
	if _points[	Globals.LetterOwnership.BOARD_ME] > _points[Globals.LetterOwnership.BOARD_OPPONENT]:	
		emit_signal("result_announced", Globals.LetterOwnership.BOARD_ME, _mode, _points, _longest_words[Globals.LetterOwnership.BOARD_ME], _best_words[Globals.LetterOwnership.BOARD_ME])
	elif _points[Globals.LetterOwnership.BOARD_OPPONENT] > _points[Globals.LetterOwnership.BOARD_ME]:
		emit_signal("result_announced", Globals.LetterOwnership.BOARD_OPPONENT, _mode, _points, _longest_words[Globals.LetterOwnership.BOARD_ME], _best_words[Globals.LetterOwnership.BOARD_ME])
	else:
		emit_signal("result_announced", Globals.LetterOwnership.ALL, _mode, _points, _longest_words[Globals.LetterOwnership.BOARD_ME], _best_words[Globals.LetterOwnership.BOARD_ME])
