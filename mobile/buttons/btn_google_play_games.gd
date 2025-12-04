extends Control

var SIGNED_IN_ICON: Texture2D = preload("res://mobile/buttons/games_controller.png")
var SIGNED_OUT_ICON: Texture2D = preload("res://mobile/buttons/games_controller_signed_out.png")

var _is_guest: bool = false


func _ready() -> void:
	if not OS.get_name() == "Android":
		hide()
		return

	show()

	var file: File = File.new()
	file.open("user://pgsgp", File.READ)
	var flag: int = file.get_8()
	file.close()

	if flag > 0:
		GooglePlayGames.sign_in()
	else:
		GooglePlayGames.sign_out()

	$Button.icon = SIGNED_IN_ICON if GooglePlayGames.is_signed_in else SIGNED_OUT_ICON

	GooglePlayGames.connect("signed_in", Callable(self, "_on_GooglePlayGames_signed_in"))
	GooglePlayGames.connect("signed_out", Callable(self, "_on_GooglePlayGames_signed_out"))


func set_is_guest(is_guest: bool = false) -> void:
	_is_guest = is_guest	


func _on_Button_pressed():
	if GooglePlayGames.is_signed_in:
		GooglePlayGames.sign_out()
	else:
		GooglePlayGames.sign_in()		


func _on_GooglePlayGames_signed_in() -> void:
	var file: File = File.new()
	file.open("user://pgsgp", File.WRITE)
	file.store_8(1)
	file.close()
	$Button.icon = SIGNED_IN_ICON


func _on_GooglePlayGames_signed_out() -> void:
	var file: File = File.new()
	file.open("user://pgsgp", File.WRITE)
	file.store_8(0)
	file.close()
	$Button.icon = SIGNED_OUT_ICON
