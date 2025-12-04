extends Control

signal equip_booster
signal remove_booster
signal switch_booster

@export var option_toggle: Texture2D
@export var enabled_toggle: Texture2D
@export var disabled_toggle: Texture2D

@onready var equip_button: Button = $Control/Btn_Toggle_Equip
@onready var slot_container: HBoxContainer = $Control/SlotContainer
@onready var slot_header: NinePatchRect = $Control/ToSpecificSlot

var current_booster: Dictionary
var currently_equipped: int = -1
var booster_level: int = 0
var booster_amount: int = 0

var can_interact: bool = true

func init(_booster, _type, discovered) -> void:
	var booster_ref = _booster["Info"]["Ref_ID"]
	current_booster = _booster
	booster_level = _type
	
	if discovered:
		booster_amount = GameLoader.player_data["booster_owned"][str(booster_ref)][str(_type)]
		$Booster_Info/BoosterTexture.modulate = Color(1,1,1,1)
		$Booster_Info/LabelBooster.text = _booster["Info"]["Class"][_type] + " " + _booster["Info"]["Name"]
		$Booster_Info/Panel_Amount/Label.text = "X " + str(booster_amount)
	else:
		hide()
		#$Booster_Info/BoosterTexture.modulate = Color(0,0,0,1)
		#$Booster_Info/LabelBooster.text = _booster["Info"]["Class"][_type] + " ???"
		#$Booster_Info/Panel_Amount/Label.text = "X ???"
	
	for i in range(0,4):
		if GameLoader.player_data["unlocked_booster_slot"][i] != 1:
			get_node("Control/SlotContainer/Slot" + str(i+1)).hide()
	
	$Booster_Info/BoosterTexture.texture = _booster["Info"]["Tier"][_type]
	$Booster_Info.texture = _booster["Info"]["Panel"]
	$Booster_Info/Panel_Amount.texture = _booster["Info"]["Panel_Info"]
	if _type == 3:
		$Booster_Info/Tier3Border.show()
		
	set_state()


func reset_state() -> void:
	pass


func set_state() -> void:
	var slot: int = 0
	for b in range(0, 4):
		if (GameLoader.player_data["equipped_booster_type"][b] == current_booster["Info"]["Ref_ID"] and 
			GameLoader.player_data["equipped_booster_level"][b] == booster_level):
			currently_equipped = slot
			slot_container.position = Vector2(18, 100)
			slot_header.position = Vector2(13, 56)
			break
		slot += 1
	
	update_state()


func update_state() -> void:
	if currently_equipped == -1 && booster_amount != 0:
		if check_available_slot() == 4:
			equip_button.disabled = true
			equip_button.modulate = Color(0.7, 0.7, 0.7, 1)
			equip_button.get_node("Label").text = "disabled"
			equip_button.get_node("Texture2D").texture = disabled_toggle
		else:
			equip_button.disabled = false
			equip_button.modulate = Color(1, 1, 1, 1)
			equip_button.get_node("Label").text = "disabled"
			equip_button.get_node("Texture2D").texture = disabled_toggle
	
	elif currently_equipped != -1 && booster_amount > 0:
		equip_button.get_node("Label").text = "enabled"
		equip_button.get_node("Texture2D").texture = enabled_toggle
		for i in range(0, 4):
			if GameLoader.player_data["equipped_booster_type"][i] != -1:
				slot_container.get_node("Slot" + str(i+1)).disabled = true
				if currently_equipped == i:
					slot_container.get_node("Slot" + str(i+1) + "/Texture2D").texture = enabled_toggle
				else:
					slot_container.get_node("Slot" + str(i+1) + "/Texture2D").texture = disabled_toggle
			elif GameLoader.player_data["equipped_booster_type"][i] == -1:
				if GameLoader.player_data["unlocked_booster_slot"][i] == 0:
					slot_container.get_node("Slot" + str(i+1)).disabled = true
					slot_container.get_node("Slot" + str(i+1) + "/Texture2D").texture = disabled_toggle
				elif GameLoader.player_data["unlocked_booster_slot"][i] == 1:
					slot_container.get_node("Slot" + str(i+1)).disabled = false
					slot_container.get_node("Slot" + str(i+1) + "/Texture2D").texture = option_toggle
	else:
		equip_button.disabled = true
		equip_button.modulate = Color(0.7, 0.7, 0.7, 1)
		equip_button.get_node("Label").text = "disabled"
		equip_button.get_node("Texture2D").texture = disabled_toggle
		

#check condition
func _on_Btn_Toggle_Equip_pressed() -> void:
	if !can_interact:
		return
	can_interact = false
	
	if currently_equipped != -1:
		var get_slot: int = currently_equipped
		currently_equipped = -1
		
		emit_signal("remove_booster", get_slot)
		$Control/Btn_Toggle_Equip/Label.text = "disabled"
		equip_button.get_node("Texture2D").texture = disabled_toggle
		$TweenDropDown.interpolate_property(slot_container, "position", Vector2(18, 100), Vector2(18, 5), 0.25, Tween.TRANS_LINEAR)
		$TweenDropDown.interpolate_property(slot_header, "position", Vector2(13, 56), Vector2(13, 6), 0.5, Tween.TRANS_LINEAR)
		$TweenDropDown.start()
	
	else:
		if check_available_slot() == 4:
			return
		
		var current_slot: int = check_available_slot()
		currently_equipped = current_slot
		emit_signal("equip_booster", current_slot, current_booster["Info"]["Ref_ID"], booster_level)
		$Control/Btn_Toggle_Equip/Label.text = "enabled"
		equip_button.get_node("Texture2D").texture = enabled_toggle
		$TweenDropDown.interpolate_property(slot_container, "position", Vector2(18, 5), Vector2(18, 100), 0.75, Tween.TRANS_EXPO)
		$TweenDropDown.interpolate_property(slot_header, "position", Vector2(13, 6), Vector2(13,56), 0.5, Tween.TRANS_EXPO)
		$TweenDropDown.start()


func check_available_slot() -> int:
	var current_slot: int = 0
	for b in range(0,4):
		if GameLoader.player_data["equipped_booster_type"][b] == -1 && GameLoader.player_data["unlocked_booster_slot"][b] == 1:
			return current_slot
		current_slot += 1
	return current_slot


func _on_Slot_pressed(this_slot) -> void:
	var get_slot: int = currently_equipped
	currently_equipped = this_slot
	emit_signal("switch_booster", get_slot, this_slot)


func _on_TweenDropDown_tween_all_completed():
	can_interact = true
