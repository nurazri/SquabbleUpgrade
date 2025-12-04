extends NinePatchRect

signal update_booster
signal call_booster_update_signal

func init(_booster) -> void:
	$LabelType.add_theme_color_override("font_color", _booster["Info"]["Color"])
	$LabelType.text = _booster["Info"]["Name"]
	$LabelDescription.text = _booster["Info"]["Description"]
	
	for i in range (1,4):
		var discovered_tier: bool = GameLoader.player_data["booster_parameters"][str(_booster["Info"]["Ref_ID"])]["Discovered_Tier_" + str(i)]
		get_node("Booster_Container/Tier_" + str(i)).init(_booster, i, discovered_tier)
		get_node("Booster_Container/Tier_" + str(i)).connect("equip_booster", Callable(self, "booster_equipped"))
		get_node("Booster_Container/Tier_" + str(i)).connect("remove_booster", Callable(self, "remove_booster"))
		get_node("Booster_Container/Tier_" + str(i)).connect("switch_booster", Callable(self, "booster_switch"))
		self.connect("update_booster", Callable(get_node("Booster_Container/Tier_" + str(i)), "update_state"))


func booster_equipped(slot, this_booster, booster_level) -> void:
	print("equipped booster")
	GameLoader.player_data["equipped_booster_type"][slot] = this_booster
	GameLoader.player_data["equipped_booster_level"][slot] = booster_level
	GameLoader.save_game_without_signal()
	emit_signal("call_booster_update_signal")


func remove_booster(slot) -> void:
	GameLoader.player_data["equipped_booster_type"][slot] = -1
	GameLoader.player_data["equipped_booster_level"][slot] = -1
	GameLoader.save_game_without_signal()
	emit_signal("call_booster_update_signal")


func booster_switch(from_slot, to_slot) -> void:
	GameLoader.player_data["equipped_booster_type"][to_slot] = GameLoader.player_data["equipped_booster_type"][from_slot]
	GameLoader.player_data["equipped_booster_level"][to_slot] = GameLoader.player_data["equipped_booster_level"][from_slot]
	GameLoader.player_data["equipped_booster_type"][from_slot] = -1
	GameLoader.player_data["equipped_booster_level"][from_slot] = -1
	GameLoader.save_game_without_signal()
	emit_signal("call_booster_update_signal")


func update_all_boosters() -> void:
	emit_signal("update_booster")
