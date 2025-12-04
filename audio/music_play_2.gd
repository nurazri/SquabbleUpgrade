extends AudioStreamPlayer

@export var no_loop_stream: AudioStream = preload("res://audio/music/play_2_late_for_work_by_helmut_schenker_edited_version.ogg")
@export var loop_stream: AudioStream = preload("res://audio/music/play_2_late_for_work_loop_by_helmut_schenker_edited_version.ogg")


func finished() -> void:
	stream = loop_stream
	play()
	print("[Audio] looped play music")


func reset() -> void:	
	stream = no_loop_stream
