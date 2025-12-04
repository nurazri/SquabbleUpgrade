extends Timer

signal command_issued

@export var level: int = 1 # (int, 1, 10)

var _time: float = 0

#var _delay_form_2: float = 0
var _delay_form_3: float = 0 
var _delay_form_4: float = 0
var _delay_form_5: float = 0
var _delay_form_6: float = 0
var _delay_form_7: float = 0

#var _delay_respell_2: float = 0
var _delay_respell_3: float = 0
var _delay_respell_4: float = 0
var _delay_respell_5: float = 0
var _delay_respell_6: float = 0
var _delay_respell_7: float = 0

#var _form_2: Array = []
var _form_3: Array = []
var _form_4: Array = []
var _form_5: Array = []
var _form_6: Array = []
var _form_7: Array = []

#var _respell_2: Array = []
var _respell_3: Array = []
var _respell_4: Array = []
var _respell_5: Array = []
var _respell_6: Array = []
var _respell_7: Array = []
var _respell_8: Array = []

#var _attempt_form_2: Array = []
var _attempt_form_3: Array = []
var _attempt_form_4: Array = []
var _attempt_form_5: Array = []
var _attempt_form_6: Array = []
var _attempt_form_7: Array = []

var _respell_temp: Dictionary = {
	#"2": [],
	"3": [],
	"4": [],
	"5": [],
	"6": [],
	"7": []
}

var _respell_next: Dictionary = {
	#"2": [],
	"3": [],
	"4": [],
	"5": [],
	"6": [],
	"7": []
}


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:	
	_respell_7 = $Search.search_words_to_respell(7, _respell_7, _respell_temp, _respell_next, _time)
	_respell_6 = $Search.search_words_to_respell(6, _respell_6, _respell_temp, _respell_next, _time)
	_respell_5 = $Search.search_words_to_respell(5, _respell_5, _respell_temp, _respell_next, _time)
	_respell_4 = $Search.search_words_to_respell(4, _respell_4, _respell_temp, _respell_next, _time)
	_respell_3 = $Search.search_words_to_respell(3, _respell_3, _respell_temp, _respell_next, _time)
	#_respell_2 = $Search.search_words_to_respell(2, _respell_2, _respell_temp, _respell_next, _time)

#	if _respell_2.size() == 2:
#		print(str(2) + " " + WordList.get_string_from_ids(_respell_2))
#	if _respell_3.size() == 3:
#		print(str(3) + " " + WordList.get_string_from_ids(_respell_3))
#	if _respell_4.size() == 4:
#		print(str(4) + " " + WordList.get_string_from_ids(_respell_4))
#	if _respell_5.size() == 5:
#		print(str(5) + " " + WordList.get_string_from_ids(_respell_5))
#	if _respell_6.size() == 6:
#		print(str(6) + " " + WordList.get_string_from_ids(_respell_6))
#	if _respell_7.size() == 7:
#		print(str(7) + " " + WordList.get_string_from_ids(_respell_7))
	
	_form_7 = $Search.search_words_to_form(7, _form_7, _attempt_form_7, _time)
	_form_6 = $Search.search_words_to_form(6, _form_6, _attempt_form_6, _time)
	_form_5 = $Search.search_words_to_form(5, _form_5, _attempt_form_5, _time)
	_form_4 = $Search.search_words_to_form(4, _form_4, _attempt_form_4, _time)
	_form_3 = $Search.search_words_to_form(3, _form_3, _attempt_form_3, _time)
	#_form_2 = $Search.search_words_to_form(3, _form_2, _attempt_form_2, _time)


func start_command(ai_level: int = level) -> void:
	level = ai_level
	
	print("[AI] level set to: " + str(level))
	
	_time = 0
	
	#_delay_form_2 = 0
	_delay_form_3 = 0 
	_delay_form_4 = 0
	_delay_form_5 = 0
	_delay_form_6 = 0
	_delay_form_7 = 0
	
	#_delay_respell_2 = 0
	_delay_respell_3 = 0
	_delay_respell_4 = 0
	_delay_respell_5 = 0
	_delay_respell_6 = 0
	_delay_respell_7 = 0
	
	_clear_memory()
	start()
	set_process(true)


func form_word(length: int) -> void:
	randomize()
	if randf() <= $Specs.specs[str(level)][str(length)]["chance_form"]:
		# Decide which array to use according to word length
		var word: Array
		match length:
			#2: word = _form_2
			3: word = _form_3
			4: word = _form_4
			5: word = _form_5
			6: word = _form_6
			7: word = _form_7
		
		# Don't form words if still cooling down
		if not $CooldownTimer.is_stopped():	
			return
				
		#randomize()
		# Found a 3-letter word? There's a 60% to 90% chance it'll skip that word.
		if randf() <= randf_range(0.6, 0.9) and _check_if_better_word_exists(length):
			word.clear()
			return
		
		if _check_letters_still_exist_in(Globals.LetterOwnership.POOL, word):
			if not word.is_empty():
				print("[AI] trying to form " +  str(length) + "-letter word " + WordList.get_string_from_ids(word) + " at " + str(_time))
			
			if word.size() == length:
				print("[AI] snatched " + str(word) + " " + str(WordList.get_string_from_ids(word)) + " at " + str(_time))
				emit_signal("command_issued", ["m", Globals.LetterOwnership.POOL, Globals.LetterOwnership.BOARD_OPPONENT, word, 0.001])
				$CooldownTimer.wait_time = 1.0 if level < Globals.AI_MAX_LEVEL else 0.01
				$CooldownTimer.start()
				reset_all_delay_forms()
		else:
			return


func respell_word(length: int) -> void:
	if $Specs.specs[str(level)].has(str(length)):
		randomize()
		if randf() <= $Specs.specs[str(level)][str(length)]["chance_respell"]:
			# Decide which array to use according to word length
			var word: Array = []
			match length:
				#2: word = _respell_2
				3: word = _respell_3
				4: word = _respell_4
				5: word = _respell_5
				6: word = _respell_6
				7: word = _respell_7

			# Don't form words if still cooling down
			if not $CooldownTimer.is_stopped():
				return

			if _check_letters_still_exist_in(Globals.LetterOwnership.ALL, word):
				if not word.is_empty():
					print("[AI] trying to respell " +  str(length) + "-letter word " + WordList.get_string_from_ids(word) + " at " + str(_time))
					emit_signal("command_issued", ["m", Globals.LetterOwnership.ALL, Globals.LetterOwnership.BOARD_OPPONENT, word, 0.001])
					$CooldownTimer.wait_time = 1.0 if level < Globals.AI_MAX_LEVEL else 0.01
					$CooldownTimer.start()
					reset_all_delay_forms()


func picker_command_succeded(_command: Array) -> void:
	_clear_memory()


func letters_snatched(_from_who: int, _longest_word: String, _picked_letters: Array) -> void:
	_clear_memory()


# Check if every letter in the found word still exists and owned by who
func _check_letters_still_exist_in(who: int, letter_ids: Array) -> bool:
	for id in letter_ids:
		if not WordList.spawned_letters.has(id):
			letter_ids.clear()
			return false
		elif who == Globals.LetterOwnership.ALL:
			return true
		elif not WordList.spawned_letters[id]["owned_by"] == who:
			letter_ids.clear()
			return false
	return true


func _check_if_better_word_exists(length: int) -> bool:
	if !_form_7.is_empty() && length < 7:
		return true
	elif !_form_6.is_empty() && length < 6:
		return true
	elif !_form_5.is_empty() && length < 5:
		return true
	elif !_form_4.is_empty() && length < 4:
		return true
	
	return false


func _clear_memory() -> void:
	#_form_2.clear()
	_form_3.clear()
	_form_4.clear()
	_form_5.clear()
	_form_6.clear()
	_form_7.clear()
	
	#_attempt_form_2.clear()
	_attempt_form_3.clear()
	_attempt_form_4.clear()
	_attempt_form_5.clear()
	_attempt_form_6.clear()
	_attempt_form_7.clear()
		
	#_respell_2.clear()
	_respell_3.clear()
	_respell_4.clear()
	_respell_5.clear()
	_respell_6.clear()
	_respell_7.clear()
	
	for t in _respell_temp:
		_respell_temp[t].clear()
	for n in _respell_next:
		_respell_next[n].clear()
	

func _on_AI_timeout():
	_time += wait_time
	
	try_respell(_delay_respell_7, "7")
	try_respell(_delay_respell_6, "6")
	try_respell(_delay_respell_5, "5")
	try_respell(_delay_respell_4, "4")
	try_respell(_delay_respell_3, "3")
	#try_respell(_delay_respell_2, "2")
	
	if _form_7.size() != 0:
		_delay_form_7 += wait_time
	if _form_6.size() != 0:
		_delay_form_6 += wait_time
	if _form_5.size() != 0:
		_delay_form_5 += wait_time
	if _form_4.size() != 0:
		_delay_form_4 += wait_time
	if _form_3.size() != 0:
		_delay_form_3 += wait_time
	#_delay_form_2 += wait_time
	
	if _delay_form_7 >= $Specs.specs[str(level)]["7"]["delay_form"]:
		form_word(7)
	if _delay_form_6 >= $Specs.specs[str(level)]["6"]["delay_form"]:
		form_word(6)
	if _delay_form_5 >= $Specs.specs[str(level)]["5"]["delay_form"]:
		form_word(5)
	if _delay_form_4 >= $Specs.specs[str(level)]["4"]["delay_form"]:
		form_word(4)
	if _delay_form_3 >= $Specs.specs[str(level)]["3"]["delay_form"]:
		form_word(3)
	
	if _time >= 60:
		_time = 0


func reset_all_delay_forms() -> void:
	_delay_form_7 = 0
	_delay_form_6 = 0
	_delay_form_5 = 0
	_delay_form_4 = 0
	_delay_form_3 = 0


func try_respell(this_respell, word_amount) -> void:
	this_respell += wait_time
	if this_respell >= 0: #$Specs.specs[str(level)][word_amount]["delay_respell"]:
		respell_word(int(word_amount))
		this_respell = 0
