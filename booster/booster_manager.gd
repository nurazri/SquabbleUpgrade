extends Node2D

signal start_game

var _BoardMe: Board
var _BoardOpponent: Board


func finish_booster_selection() -> void:
	emit_signal("start_game")


func set_boards(board_me: Board, board_opponent: Board) -> void:
	_BoardMe = board_me
	_BoardOpponent = board_opponent


func return_event_type(current_ai_level) -> bool:
	if current_ai_level == 10:
		return true
	if current_ai_level == 14:
		return true
	if current_ai_level == 17:
		return true
	if current_ai_level == 30:
		return true
	
	return false


func set_temp_booster(current_ai_level) -> void:
	if current_ai_level == 14:
		_BoardMe.get_node("UI/Booster/Booster_Slot1").init(Globals.BoosterType.FREEZE, 2)
	if current_ai_level == 17: 
		_BoardMe.get_node("UI/Booster/Booster_Slot1").init(Globals.BoosterType.FREEZE, 1)
		_BoardMe.get_node("UI/Booster/Booster_Slot2").init(Globals.BoosterType.FREEZE, 2)
	if current_ai_level == 30: 
		_BoardMe.get_node("UI/Booster/Booster_Slot1").init(Globals.BoosterType.BLAST, 1)


func set_equipped_booster() -> void:
	var get_booster_type: Array = GameLoader.player_data["equipped_booster_type"]
	var get_booster_level: Array = GameLoader.player_data["equipped_booster_level"]
	
	for b in range(0,4):
		if get_booster_type[b] != -1:
			_BoardMe.get_node("UI/Booster/Booster_Slot" + str(b+1)).init(get_booster_type[b], get_booster_level[b])


func check_consumed_booster() -> void:
	var get_booster_type: Array = GameLoader.player_data["equipped_booster_type"]
	var get_booster_level: Array = GameLoader.player_data["equipped_booster_level"]
	
	for b in range(0,4):
		if _BoardMe.get_node("UI/Booster/Booster_Slot" + str(b+1))._booster_used:
			GameLoader.player_data["booster_owned"][str(get_booster_type[b])][str(get_booster_level[b])] -= 1
			GameLoader.update_achievement_value("achievement_use_booster_" + str(get_booster_level[b]), "points", 1)
			if GameLoader.player_data["booster_owned"][str(get_booster_type[b])][str(get_booster_level[b])] == 0:
				get_booster_type[b] = -1
				get_booster_level[b] = -1


func _on_BoardMe_booster_used(boosterType: int, boosterLevel: int) -> void:
	Analytics.log_event(Globals.Analytics.ALL, Analytics.EVENT_BOOSTER_USED, Analytics.booster_params(get_tree().root.get_node("Game/Pool")._ai_level, boosterType, boosterLevel))
	_return_booster(Globals.LetterOwnership.BOARD_ME, boosterType, boosterLevel)
	get_parent().get_node("UI/LevelReview").update_condition_booster(boosterType, boosterLevel)


func _on_BoardOpponent_booster_used(boosterType: int, boosterLevel: int) -> void:
	_return_booster(Globals.LetterOwnership.BOARD_OPPONENT, boosterType, boosterLevel)


func _return_booster(from_who: int, boosterType: int, boosterLevel: int) -> void:
	var _returnOpposingBoard = _BoardOpponent if from_who == Globals.LetterOwnership.BOARD_ME else _BoardMe
	var _returnSelfBoard: Board = _BoardMe if from_who == Globals.LetterOwnership.BOARD_ME else _BoardOpponent
	
	var _booster_attribute = Globals.BoosterAttributes[boosterType].Stat
	var _booster_info = Globals.BoosterAttributes[boosterType].Info
	if boosterType == Globals.BoosterType.BLAST:
		match boosterLevel:
			1: _returnOpposingBoard.get_node("BoardGrid").remove_letters(_booster_attribute.Value.Tier_1)
			2: _returnOpposingBoard.get_node("BoardGrid").remove_letters(_booster_attribute.Value.Tier_2)
			3: _returnOpposingBoard.get_node("BoardGrid").remove_letters(_booster_attribute.Value.Tier_3)
	if boosterType == Globals.BoosterType.FREEZE:
		match boosterLevel:
			1: _returnOpposingBoard.set_interactivity(false, _booster_attribute.Duration.Tier_1)
			2: _returnOpposingBoard.set_interactivity(false, _booster_attribute.Duration.Tier_2)
			3: _returnOpposingBoard.set_interactivity(false, _booster_attribute.Duration.Tier_3)
	if boosterType == Globals.BoosterType.PROTECT:
		match boosterLevel:
			1: _returnSelfBoard.protect_board(_booster_attribute.Duration.Tier_1, _booster_info.Tier[1])
			2: _returnSelfBoard.protect_board(_booster_attribute.Duration.Tier_2, _booster_info.Tier[2])
			3: _returnSelfBoard.protect_board(_booster_attribute.Duration.Tier_3, _booster_info.Tier[3])
	if boosterType == Globals.BoosterType.BREAK:
		match boosterLevel:
			1: _returnOpposingBoard.get_node("BoardGrid").remove_letters(_booster_attribute.Value.Tier_1, true)
			2: _returnOpposingBoard.get_node("BoardGrid").remove_letters(_booster_attribute.Value.Tier_2, true)
			3: _returnOpposingBoard.get_node("BoardGrid").remove_letters(_booster_attribute.Value.Tier_3, true)
	
