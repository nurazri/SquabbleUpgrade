extends Control

var player_board_ref: Node2D = null
var challenge_condition = []
var challenge_parameter = []
var challenge_requirement = []

var current_requirement = [0,0,0]


func debug_condition() -> void:
	for i in range(0,3):
		current_requirement[i] = challenge_requirement[i]


func update_condition_win_status(score: int, opponent_score: int) -> void:
	for i in range(0,3):
		match challenge_condition[i]:
			Globals.Challenge.SCORE:
				current_requirement[i] = challenge_requirement[i]
			Globals.Challenge.OVER_WIN:
				if score >= challenge_requirement[i]:
					current_requirement[i] = challenge_requirement[i]
			Globals.Challenge.FLAWLESS_WIN:
				if opponent_score == 0:
					current_requirement[i] = challenge_requirement[i]
			Globals.Challenge.SPECIFIC_WIN:
				if score == challenge_requirement[i]:
					current_requirement[i] = challenge_requirement[i]


func update_condition_letters_picked(picked_letters: Array, steal_status: Array, letter_points: int) -> void:
	#print(steal_status[0])
	for i in range(0,3):
		match challenge_condition[i]:
			Globals.Challenge.STEAL:
				if challenge_parameter[i] == 0:
					if steal_status[0] == true:
						current_requirement[i] = current_requirement[i] + 1
				elif challenge_parameter[i] > 0:
					if steal_status[0] == true && steal_status[1] >= challenge_parameter[i]:
						current_requirement[i] = current_requirement[i] + 1
			Globals.Challenge.FORM:
				if picked_letters.size() >= challenge_parameter[i]:
					current_requirement[i] = current_requirement[i] + 1
			Globals.Challenge.FORM_WITH:
				if picked_letters[0].letter == challenge_parameter[i]:
					current_requirement[i] = current_requirement[i] + 1
			Globals.Challenge.FORM_POINTS:
				if letter_points >= challenge_parameter[i]:
					current_requirement[i] = current_requirement[i] + 1


func update_condition_booster(booster_type: int, booster_level: int) -> void:
	for i in range(0,3):
		match challenge_condition[i]:
			Globals.Challenge.USE_BOOSTER:
				if booster_type == challenge_parameter[i]:
					current_requirement[i] = current_requirement[i] + 1


func return_stars() -> int:
	var current_stars: int = 0
	for i in range(0,3):
		if current_requirement[i] >= challenge_requirement[i]:
			current_stars = current_stars + 1
	return current_stars


func fetch_level_condition(_this_level: int) -> void:
	current_requirement = [0,0,0]
	var this_opponent: int = 0
	var get_challenge: Dictionary = {}
	for i in Globals.OpponentList:
		if (_this_level <= Globals.OpponentList[i]["Max_Level"] && _this_level >= Globals.OpponentList[i]["Min_Level"]):
			this_opponent = i
			break
	
	var current_stage: int = _this_level - (Globals.OpponentList[this_opponent]["Min_Level"] - 1)
	print(Globals.OpponentList[this_opponent])
	print(Globals.OpponentList[this_opponent]["Challenge"])
	for current in Globals.OpponentList[this_opponent]["Challenge"]:
		var challenge_data: Dictionary = Globals.OpponentList[this_opponent]["Challenge"][str(current)]
		if current_stage >= challenge_data["From"][0] && current_stage <= challenge_data["From"][1]:
			get_challenge = challenge_data
			break
	
	
	challenge_condition = get_challenge["Type"]
	challenge_parameter = get_challenge["Parameter"]
	challenge_requirement = get_challenge["Requirement"]
	for i in range(0,3):
		var requirement_label = get_node("Panel/Requirement_" + str(i+1) + "_Star")
		match challenge_condition[i]:
			Globals.Challenge.SCORE: requirement_label.text = "Score more than " + str(challenge_requirement[i]) + " points"
			Globals.Challenge.STEAL:
				if challenge_requirement[i] > 1 && challenge_parameter[i] != 0:
					requirement_label.text = "Steal a " + str(challenge_parameter[i]) + "-letter word " + str(challenge_requirement[i]) + " times"
				elif challenge_requirement[i] == 1 && challenge_parameter[i] != 0:
					requirement_label.text = "Steal a " + str(challenge_parameter[i]) + "-letter word "
				elif challenge_requirement[i] > 1 && challenge_parameter[i] == 0:
					requirement_label.text = "Steal an opponents word " + str(challenge_requirement[i]) + " times"
				elif challenge_requirement[i] == 1 && challenge_parameter[i] == 0:
					requirement_label.text = "Steal an opponents word"
			Globals.Challenge.FORM: 
				if challenge_requirement[i] > 1:
					requirement_label.text = "Form a " + str(challenge_parameter[i]) + "-letter word " + str(challenge_requirement[i]) + " times"
				else:
					requirement_label.text = "Form a " + str(challenge_parameter[i]) + "-letter word "
			Globals.Challenge.FORM_WITH: 
				if challenge_requirement[i] > 1:
					requirement_label.text = "Form a word starting with " + str(challenge_parameter[i]) + " " + str(challenge_requirement[i]) + " times"
				else:
					requirement_label.text = "Form a word starting with " + str(challenge_parameter[i])
			Globals.Challenge.FORM_POINTS:
				if challenge_requirement[i] > 1:
					requirement_label.text = "Form a word with more than" + str(challenge_parameter[i]) + " points " + str(challenge_requirement[i]) + " times"
				else:
					requirement_label.text = "Form a word with more than" + str(challenge_parameter[i]) + " points"
			Globals.Challenge.USE_BOOSTER:
				if challenge_requirement[i] > 1:
					requirement_label.text = "Use " + Globals.BoosterAttributes[str(challenge_parameter[i])]["Name"]  + " booster " + str(challenge_requirement[i]) + " times" 
				else:
					requirement_label.text = "Use " + str(challenge_parameter[i]) + " booster once"
			Globals.Challenge.OVER_WIN: requirement_label.text = "Win with " + str(challenge_requirement[i]) + " points or more"
			Globals.Challenge.FLAWLESS_WIN: requirement_label.text = "Opponent scores zero points"
			Globals.Challenge.SPECIFIC_WIN: requirement_label.text = "Win with exactly " + str(challenge_requirement[i]) + " points"
