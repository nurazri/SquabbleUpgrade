extends Page

signal ResetSelectedAvatar

@export var _ScnProfileLetter: PackedScene

@onready var _AvatarInfo = $UI_Profile/AvatarInfo
@onready var _UserInfo = $UI_Profile/UserInfo
@onready var _GameInfo = $UI_Profile/GameInfo/Panel

var in_submenu: bool = false

func on_Load() -> void:
	_load_profile_Info()


func _load_profile_Info() -> void:
	_AvatarInfo.get_node("Avatar").texture = Globals.AvatarTextures[int(GameLoader.get_save_data("avatar"))]
#	_UserInfo.get_node("Name").text = GameLoader.get_save_data("squabble_name")
	_UserInfo.get_node("Coin/Amount").text = str(GameLoader.load_currency("coins"))
	_UserInfo.get_node("Diamond/Amount").text = str(GameLoader.load_currency("diamonds"))
	
	var best_word_list: Array = GameLoader.player_data["best_word_list"]
	var current: int = 0
	for child in $UI_Profile/GameInfo/Best_Word_List.get_children():
		child.get_node("Label").text = ""
		if current < best_word_list.size():
			child.get_node("Label").text = best_word_list[current][1] + " " + "(" + str(best_word_list[current][0]) + " PTS)"
			current += 1
		else:
			pass


func _on_BtnEditAvatar_pressed() -> void:
	emit_signal("redirect_page", Globals.PageType.INVENTORY, "Avatar")
