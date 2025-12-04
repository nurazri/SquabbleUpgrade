extends AudioStreamPlayer

@export var no_loop_stream: AudioStream = preload("res://audio/music/play_1_brouhaha_by_crusade_chong_and_cyrus_kwok.ogg")
@export var loop_stream: AudioStream = preload("res://audio/music/play_1_brouhaha_loop_by_crusade_chong_and_cyrus_kwok.ogg")


func finished() -> void:	
	stream = loop_stream
	play()
	print("[Audio] looped play music")


func reset() -> void:	
	stream = no_loop_stream
