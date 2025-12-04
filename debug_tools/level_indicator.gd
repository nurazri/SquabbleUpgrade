extends Label


func _ready() -> void:
	hide()


func _on_Timer_timeout() -> void:
	var game: Node2D = get_tree().root.get_node("Game")
	if game:
		var pool: Node2D = game.get_node("Pool")
		visible = pool.visible
		text = "Level " + str(pool._ai_level)
