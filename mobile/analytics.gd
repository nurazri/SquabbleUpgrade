extends Node

const EVENT_LOGIN: String = "login"
const EVENT_QUIT_REQUEST: String = "quit_request"
const EVENT_TUTORIAL_BEGIN: String = "tutorial_begin"
const EVENT_TUTRORIAL_COMPLETE: String = "tutorial_complete"
const EVENT_LEVEL_PLAYED: String = "level_played"
const EVENT_LEVEL_COMPLETE: String = "level_complete"
const EVENT_LEVEL_RETRIED: String = "level_retried"
const EVENT_CUSTOM_PLAYED: String = "custom_played"
const EVENT_POINTS_ACQUIRED: String = "points_acquired"
const EVENT_STARS_ACQUIRED: String = "stars_acquired"
const EVENT_BOOSTER_USED: String = "booster_used"

#const EVENT_GAME_MODES: Dictionary = {
#	str(Globals.GameMode.TUTORIAL): "game_mode_tutorial",
#	str(Globals.GameMode.LOCAL_PLAY): "game_mode_local_play",
#	str(Globals.GameMode.VS_AI): "game_mode_vs_ai",
#	str(Globals.GameMode.ONLINE_PLAY): "game_mode_online_play"
#}


var login_params: Dictionary = { 
	"locale": OS.get_locale(),
	"screen_dpi": DisplayServer.screen_get_dpi(),
	"time": Time.get_datetime_dict_from_system()
}


func level_params(current_level: int) -> Dictionary: 
	return {
		"level": current_level,
		"locale": OS.get_locale(),
	}


func points_params(current_level: int, points: Dictionary)  -> Dictionary:
	var outcome: String = "won" if points[Globals.LetterOwnership.BOARD_ME] > points[Globals.LetterOwnership.BOARD_OPPONENT] else "lost"
	outcome = "tied" if points[Globals.LetterOwnership.BOARD_ME] == points[Globals.LetterOwnership.BOARD_OPPONENT] else outcome

	return {
		"result": outcome,
		"level": current_level,
		"player_points": points[Globals.LetterOwnership.BOARD_ME],
		"opponent_points": points[Globals.LetterOwnership.BOARD_OPPONENT],
		"locale": OS.get_locale()
	}


func stars_params(current_level: int, points: Dictionary, stars: int) -> Dictionary:
	var stars_dict = {
		"stars": stars
	}
	GameLoader.merge_dict(stars_dict, points_params(current_level, points))
	return stars_dict


func booster_params(current_level: int, booster_type: int, booster_level: int) -> Dictionary:
	var booster_type_string: String = Globals.BoosterAttributes[booster_type]["Info"]["Name"]
	var booster_dict = {
		"booster_type": booster_type_string,
		"booster_level": booster_level
	}
	GameLoader.merge_dict(booster_dict, level_params(current_level))
	return booster_dict


# Usage example: Analytics.log_event(Globals.Analytics.ALL, "quit_request", Analytics.login_params, OS.get_ticks_msec())
func log_event(which_one: int, event: String, params: Dictionary, value: int = Time.get_ticks_msec()) -> void:
	if Globals.analytics_turned_on:
		match which_one:
			Globals.Analytics.ALL:
				FirebaseAnalytics.logEvent(event, params)
				if not event == Analytics.EVENT_TUTORIAL_BEGIN:
					if not event == Analytics.EVENT_TUTRORIAL_COMPLETE:	
						if not event == Analytics.EVENT_LEVEL_PLAYED:
							if not event == Analytics.EVENT_LEVEL_COMPLETE:
								ByteBrew.new_custom_event(event, JSON.new().stringify(params))
				if value:
					Tenjin.logEventWithValue(event, value)					
				else:
					Tenjin.logEvent(event)					
			
			Globals.Analytics.FIREBASE:
				FirebaseAnalytics.logEvent(event, params)
			
			Globals.Analytics.TENJIN:
				if value:
					Tenjin.logEventWithValue(event, value)
				else:
					Tenjin.logEvent(event)

			Globals.Analytics.BYTEBREW:
				if not event == Analytics.EVENT_TUTORIAL_BEGIN:
					if not event == Analytics.EVENT_TUTRORIAL_COMPLETE:	
						if not event == Analytics.EVENT_LEVEL_PLAYED:
							if not event == Analytics.EVENT_LEVEL_COMPLETE:
								ByteBrew.new_custom_event(event, JSON.new().stringify(params))
						
