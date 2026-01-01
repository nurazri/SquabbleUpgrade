extends Page

#signal on_reset  # For resetting achievements

@export var _ScnAchievement: PackedScene
@onready var achievement_container: ScrollContainer = $UI/Achievement_Container

func reload() -> void:
	GameLoader.load_achievement()
	var vbox = achievement_container.get_node("VBoxContainer")
	for child in vbox.get_children():
		child.queue_free()
	spawn_data()


#func spawn_data() -> void:
	#var vbox = achievement_container.get_node("VBoxContainer")
	#for a in GameLoader.achievement_data:
		#var achievement_object = _ScnAchievement.instantiate()
		#achievement_object.init(GameLoader.achievement_data[a], str(a))
		#achievement_object.connect("reward_claimed", Callable(self, "_on_Achievement_on_claimed"))
		#self.connect("on_reset", Callable(achievement_object, "_on_achievement_page_reset_progress"))
		#vbox.add_child(achievement_object)
		
func spawn_data() -> void:
	for a in GameLoader.achievement_data:
		var achievement_object = _ScnAchievement.instantiate()
		achievement_object.init(GameLoader.achievement_data[a], str(a))
		achievement_object.connect("reward_claimed", Callable(self, "_on_Achievement_on_claimed"))
		self.connect("on_reset", Callable(achievement_object, "_on_achievement_page_reset_progress"))
		achievement_container.get_node("VBoxContainer").add_child(achievement_object)


func _on_Achievement_on_claimed(coin: int, diamond: int) -> void:
	send_page_update(coin, diamond)
	
#func send_page_update(coins: int, diamonds: int) -> void:
	#$UI/CoinLabel.text = str(coins)
	#$UI/DiamondLabel.text = str(diamonds)

func close_page() -> void:
	achievement_container.set_v_scroll(0)
	hide()  # Hide page instead of calling undefined return_page()
	emit_signal("page_closed")  # Optional: notify parent that page is closed


func _on_Reset_Progress_pressed() -> void:
	GameLoader.clear_achievement()
	emit_signal("on_reset")
