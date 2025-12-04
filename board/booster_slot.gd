extends NinePatchRect

signal booster_used

var _booster_set: int = -1
var _booster_level: int = -1
var _booster_used: bool = false
var _booster_init: bool = false


func init(booster_set, booster_level, show = false):
	visible = show
	_booster_set = booster_set
	_booster_level = booster_level
	_booster_init = true
	$Panel.texture = Globals.BoosterAttributes[_booster_set].Info.Panel
	$Icon.texture = Globals.BoosterAttributes[_booster_set].Info.Tier[_booster_level]


func use_booster() -> void:
	if !_booster_used:
		$Panel.modulate = Color("#646464")
		$Icon.modulate = Color("#646464")
		emit_signal("booster_used", _booster_set, _booster_level)
		_booster_used = true


func reset_booster() -> void:
	hide()
	$Panel.modulate = Color("#ffffff")
	$Icon.modulate = Color("#ffffff")
	_booster_used = false
	_booster_init = false
