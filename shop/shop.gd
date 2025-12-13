extends Control

signal update_listings
signal page_closed  # Optional: notify parent page has closed

@export var enabled_toggle: Texture2D
@export var disabled_toggle: Texture2D
@export var _ScnBoosterListing: PackedScene

func _ready() -> void:
	FirebaseFirestoreDocument.connect("update_currency_done", Callable(self, "update_value"))
	GoogleIapModule.connect("update_diamond_value", Callable(self, "update_value"))


func _on_Shop_Page_visibility_changed() -> void:
	if visible:
		check_purchase_conditions()
		var booster_container = get_node("ScrollContainer/VBoxContainer/BoosterContainer")
		for child in booster_container.get_children():
			child.queue_free()
		for b in Globals.BoosterAttributes:
			for i in range(1, 4):
				if GameLoader.player_data["booster_parameters"][str(b)]["Discovered_Tier_" + str(i)] == 1:
					var listing = _ScnBoosterListing.instantiate()
					booster_container.add_child(listing)
					listing.initialize_listing(Globals.BoosterAttributes[b], i)
					listing.connect("booster_purchase", Callable(self, "_on_booster_purchase"))
					self.connect("update_listings", Callable(listing, "_on_update_listings"))
		
		if booster_container.get_child_count() == 0:
			print(booster_container.get_child_count())
			get_node("ScrollContainer/VBoxContainer/TitleBar_(Booster)").hide()
		else:
			print(booster_container.get_child_count())
			get_node("ScrollContainer/VBoxContainer/TitleBar_(Booster)").show()
	else:
		GameLoader.save_game()


func _on_booster_purchase() -> void:
	emit_signal("update_listings")


func on_btn_buycoin(value: int) -> void:
	match value:
		1:
			if GameLoader.load_currency("diamonds") >= 30:
				GameLoader.save_currency("coins", 500)
				GameLoader.save_currency("diamonds", -30)
		2:
			if GameLoader.load_currency("diamonds") >= 50:
				GameLoader.save_currency("coins", 1000)
				GameLoader.save_currency("diamonds", -50)
		3:
			if GameLoader.load_currency("diamonds") >= 230:
				GameLoader.save_currency("coins", 5000)
				GameLoader.save_currency("diamonds", -230)
		4:
			if GameLoader.load_currency("diamonds") >= 400:
				GameLoader.save_currency("coins", 10000)
				GameLoader.save_currency("diamonds", -400)
	check_purchase_conditions()
	update_value()


func check_purchase_conditions() -> void:
	var coins_container = $ScrollContainer/VBoxContainer/GoldContainer
	var diamond_costs = [30, 50, 230, 400]
	for i in range(4):
		var buy_button = coins_container.get_node("CoinsItem" + str(i + 1) + "/BuyButton")
		var nine_patch = buy_button.get_node("NinePatchRect")
		if GameLoader.load_currency("diamonds") >= diamond_costs[i]:
			buy_button.disabled = false
			nine_patch.texture = enabled_toggle
		else:
			buy_button.disabled = true
			nine_patch.texture = disabled_toggle


func on_btn_buydiamond(value: int) -> void:
	var diamond_amounts = [50, 200, 600, 1200]
	var inapp_ids = ["inapp1", "inapp2", "inapp3", "inapp4"]
	if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
		GoogleIapModule.on_purchase(inapp_ids[value - 1])
	else:
		GameLoader.save_currency("diamonds", diamond_amounts[value - 1])
		update_value()


func update_value() -> void:
	if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
		send_page_update(FirebaseFirestoreDocument.player_document.coins, FirebaseFirestoreDocument.player_document.diamonds)
	else:
		send_page_update(GameLoader.load_currency("coins"), GameLoader.load_currency("diamonds"))


# Update UI labels for coins and diamonds
func send_page_update(coins: int, diamonds: int) -> void:
	$ScrollContainer/VBoxContainer/GoldContainer/CoinAmountLabel.text = str(coins)
	$ScrollContainer/VBoxContainer/DiamondContainer/DiamondAmountLabel.text = str(diamonds)


func close_page() -> void:
	hide()  # Hide current page
	emit_signal("page_closed")  # Optional: notify parent


func update_text() -> void:
	if GoogleIapModule.purchasable_inapp.is_empty():
		return
	for i in range(1, 5):
		var btn_path = "BottomPanel/VBoxContainer/DiamondContainer/DiamondsItem" + str(i) + "/BuyButton"
		var buy_button = get_node(btn_path)
		buy_button.text = GoogleIapModule.purchasable_inapp["inapp" + str(i)].price


func _on_Shop_Page_draw() -> void:
	update_text()


func _on_Btn_RemoveAdMonthly_pressed() -> void:
	pass # Replace with your function body


func _on_Btn_RemoveAdYearly_pressed() -> void:
	pass # Replace with your function body
