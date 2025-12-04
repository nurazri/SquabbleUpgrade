extends Node

var bytebrew 

enum ProgressionType { Started, Completed, Failed }

func _ready() -> void:
	var gameId
	var sdkKey

	if ProjectSettings.has_setting('ByteBrew/GameId'):
		gameId = ProjectSettings.get_setting('ByteBrew/GameId')
	if ProjectSettings.has_setting('ByteBrew/SdkKey'):
		sdkKey = ProjectSettings.get_setting('ByteBrew/SdkKey')
	if Engine.has_singleton("ByteBrew"):
		bytebrew = Engine.get_singleton("ByteBrew")
		var versionForByteBrew = "Dev" # Don't change this line, or automated builds will not have the correct version!
		bytebrew.InitializeByteBrew(gameId, sdkKey, Engine.get_version_info(), versionForByteBrew)
		# bytebrew.StartPushNotifications()


func new_custom_event(s: String="", n=null) -> void:
	if bytebrew:
		if not s.is_empty():
			if n is String:
				bytebrew.NewCustomEventWithStringValue(s, n)
				return
			if n is float or n is int:
				bytebrew.NewCustomEventWithFloatValue(s, n)
				return
			bytebrew.NewCustomEvent(s)
	return


func new_progression_event(progression: int, Environment: String, Stage: String, n=null) -> void:
	var _progression: String = "Started"
	match progression:
		ProgressionType.Started:
			_progression = "Started"
		ProgressionType.Completed:
			_progression = "Completed"
		ProgressionType.Failed:
			_progression = "Failed"

	if bytebrew:
		if n is float or n is int:
			bytebrew.NewProgressionEventWithFloatScore(_progression, Environment, Stage, n)
			return
		bytebrew.NewProgressionEvent(_progression, Environment, Stage)
	return

		
