extends Control

signal OnSelectAvatar

var _avatar_id: int
var _can_equip: bool

func init(avatar: int, isEquipped: bool, isLocked: bool) -> void:
	_avatar_id = avatar
	if isLocked:
		$Avatar.texture = Globals.AvatarLockedTextures[avatar]
		_can_equip = false
	else:
		$Avatar.texture = Globals.AvatarTextures[avatar]
		_can_equip = true
		
	if isEquipped:
		$Selected.show()


func _unselect_avatar() -> void:
	$Selected.hide()


func _on_BtnSetAvatar_pressed() -> void:
	if _can_equip:
		GameLoader.set_save_data("avatar", _avatar_id)
		GameLoader.save_game()
