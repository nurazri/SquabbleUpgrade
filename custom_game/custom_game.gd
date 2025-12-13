extends Control

signal start_custom_game

var this_opponent: int = 0
var this_word_mix_level: int = 0
var this_opponent_reaction_level: int = 0
var this_opponent_dictionary_level: int = 0
var this_point_condition: int = 0

var word_mix_level: Array = ["beginner", "medium", "hard"]
var ai_reaction_level: Array = [17, 47, 77, 107]
var ai_reaction_level_description: Array = ["easy", "medium", "hard", "unfair"]
var ai_dictionary_level: Array = ["elementary", "secondary", "college", "professional"]
var point_condition: Array = [30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]


func _on_Custom_Game_Page_visibility_changed():
	pass
# Uncomment if you want to reset settings on page show
#	if visible:
#		this_opponent = 0
#		this_word_mix_level = 0
#		this_opponent_reaction_level = 0
#		this_opponent_dictionary_level = 0
#		this_point_condition = 0
#		_set_opponent(0)
#		_set_word_mix_level(0)
#		_set_opponent_reaction_level(0)
#		_set_opponent_dictionary_level(0)
#		_set_point_condition(0)


func _set_opponent(increment: int) -> void:
	this_opponent += increment
	if this_opponent > (Globals.OpponentList.size() - 1):
		this_opponent = 0
	elif this_opponent < 0:
		this_opponent = Globals.OpponentList.size() - 1
	
	$Panel/OpponentSelect/LabelPanel/Label.text = Globals.OpponentList[this_opponent]["Name"]
	$Panel/Avatar/Picture.texture = Globals.OpponentList[this_opponent]["Avatar"]


func _set_word_mix_level(increment: int) -> void:
	this_word_mix_level += increment
	if this_word_mix_level > (word_mix_level.size() - 1):
		this_word_mix_level = 0
	elif this_word_mix_level < 0:
		this_word_mix_level = word_mix_level.size() - 1
	
	$Panel/WordMix/LabelPanel/Label.text = word_mix_level[this_word_mix_level]


func _set_opponent_reaction_level(increment: int) -> void:
	this_opponent_reaction_level += increment
	if this_opponent_reaction_level > (ai_reaction_level.size() - 1):
		this_opponent_reaction_level = 0
	elif this_opponent_reaction_level < 0:
		this_opponent_reaction_level = ai_reaction_level.size() - 1
	
	$Panel/DifficultyLevel/LabelPanel/Label.text = ai_reaction_level_description[this_opponent_reaction_level]


func _set_opponent_dictionary_level(increment: int) -> void:
	this_opponent_dictionary_level += increment
	if this_opponent_dictionary_level > (ai_dictionary_level.size() - 1):
		this_opponent_dictionary_level = 0
	elif this_opponent_dictionary_level < 0:
		this_opponent_dictionary_level = ai_dictionary_level.size() - 1
	
	$Panel/DictionaryLevel/LabelPanel/Label.text = ai_dictionary_level[this_opponent_dictionary_level]


func _set_point_condition(increment: int) -> void:
	this_point_condition += increment
	if this_point_condition > (point_condition.size() - 1):
		this_point_condition = 0
	elif this_point_condition < 0:
		this_point_condition = point_condition.size() - 1
	
	$Panel/TargetPoints/LabelPanel/Label.text = str(point_condition[this_point_condition])


func _on_Btn_Start_Easy_pressed():
	this_opponent = 1
	this_word_mix_level = 0
	this_opponent_reaction_level = 0
	this_opponent_dictionary_level = 0
	this_point_condition = 1
	_on_Btn_StartCustomGame_pressed()


func _on_Btn_Start_Medium_pressed():
	this_opponent = 7
	this_word_mix_level = 1
	this_opponent_reaction_level = 1
	this_opponent_dictionary_level = 1
	this_point_condition = 5
	_on_Btn_StartCustomGame_pressed()


func _on_Btn_Start_Hard_pressed():
	this_opponent = 10
	this_word_mix_level = 2
	this_opponent_reaction_level = 2
	this_opponent_dictionary_level = 2
	this_point_condition = 9
	_on_Btn_StartCustomGame_pressed()


func _on_Btn_Start_Unfair_pressed():
	this_opponent = 11
	this_word_mix_level = 2
	this_opponent_reaction_level = 3
	this_opponent_dictionary_level = 3
	this_point_condition = 14
	_on_Btn_StartCustomGame_pressed()


func _on_Btn_StartCustomGame_pressed():
	emit_signal("start_custom_game", this_opponent, word_mix_level[this_word_mix_level], ai_dictionary_level[this_opponent_dictionary_level], ai_reaction_level[this_opponent_reaction_level], point_condition[this_point_condition])
	hide()
