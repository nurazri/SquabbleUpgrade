extends Page

@export var _ScnAchievement: PackedScene
@onready var achievement_container: ScrollContainer = $UI/Achievement_Container


func reload() -> void:
	GameLoader.load_achievement()
	for child in achievement_container.get_node("VBoxContainer").get_children():
		child.queue_free()
	spawn_data()


func spawn_data() -> void:
	for a in GameLoader.achievement_data:
		var achievement_object = _ScnAchievement.instantiate()
		achievement_object.init(GameLoader.achievement_data[a], str(a))
		achievement_object.connect("reward_claimed", Callable(self, "_on_Achievement_on_claimed"))
		self.connect("on_reset", Callable(achievement_object, "_on_achievement_page_reset_progress"))
		achievement_container.get_node("VBoxContainer").add_child(achievement_object)


func _on_Achievement_on_claimed(coin: int, diamond: int) -> void:
	send_page_update(coin, diamond)


func close_page() -> void:
	achievement_container.set_v_scroll(0)
	return_page()


func _on_Reset_Progress_pressed():
	GameLoader.clear_achievement()
	emit_signal("on_reset")
