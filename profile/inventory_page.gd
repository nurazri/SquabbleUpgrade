extends Control

signal ResetSelectedAvatar
signal UpdateAllBooster

@export var _ScnAvatarSelect: PackedScene
@export var _ScnBoosterInfo: PackedScene

var extra_params: String = ""

func on_Load() -> void:
	_load_inventory_info()


func _load_inventory_info() -> void:
	var avatar_container = get_node("GameInfo/ScrollContainerAvatar/GridContainer")
	for child in avatar_container.get_children():
		child.queue_free()
	
	for a in Globals.CurrentUnlockableAvatar:
		var isEquipped: bool = a == GameLoader.player_data["avatar"]
		var avatar_object = _ScnAvatarSelect.instantiate()
		if GameLoader.player_data["owned_avatars"].has(str(a)):
			avatar_object.init(a, isEquipped, false)
		else:
			avatar_object.init(a, isEquipped, true)
		
		avatar_object.connect("OnSelectAvatar", Callable(self, "_on_Avatar_selection_set"))
		self.connect("ResetSelectedAvatar", Callable(avatar_object, "_unselect_avatar"))
		avatar_container.add_child(avatar_object)
		
	# For Boosters
	var booster_container = get_node("GameInfo/ScrollContainerBooster/VBoxContainer")
	for child in booster_container.get_children():
		child.queue_free()
	
	for b in Globals.BoosterAttributes:
		var get_ref_id: String = str(Globals.BoosterAttributes[b]["Info"]["Ref_ID"])
		var discovered: bool = GameLoader.player_data["booster_parameters"][get_ref_id]["Discovered"]
		if discovered:
			var booster_object = _ScnBoosterInfo.instantiate()
			booster_container.add_child(booster_object)
			booster_object.init(Globals.BoosterAttributes[b])
			booster_object.connect("call_booster_update_signal", Callable(self, "_forward_booster_signal"))
			self.connect("UpdateAllBooster", Callable(booster_object, "update_all_boosters"))


func _on_Avatar_selection_set() -> void:
	emit_signal("ResetSelectedAvatar")


func _forward_booster_signal() -> void:
	emit_signal("UpdateAllBooster")


func set_inventory_state(show: bool, navigate: String) -> void:
	var return_page = ("Booster" if navigate == "Avatar" else
						"Avatar" if navigate == "Booster" else "")
	
	get_node("GameInfo/ScrollContainerAvatar").set_v_scroll(0)
	get_node("GameInfo/ScrollContainerBooster").set_v_scroll(0)
	
	get_node("GameInfo/ScrollContainer" + navigate).show()
	get_node("GameInfo/ScrollContainer" + return_page).hide()
	get_node(navigate + "Selection").modulate.a = 1.0
	get_node(return_page + "Selection").modulate.a = 0.5


func _on_BtnAvatarSelect_pressed() -> void:
	set_inventory_state(true, "Avatar")


func _on_BtnBoosterSelect_pressed() -> void:
	set_inventory_state(true, "Booster")


func _on_Inventory_Page_visibility_changed() -> void:
	if extra_params != "":
		set_inventory_state(true, extra_params)
		extra_params = ""
	else:
		set_inventory_state(true, "Booster")
