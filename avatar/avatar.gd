extends TextureRect

func set_avatar(avatar: Texture2D, background: Texture2D) -> void:
	texture = background
	$Picture.texture = avatar	
