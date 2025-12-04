extends Page

signal update_listings

@export var enabled_toggle: Texture2D
@export var disabled_toggle: Texture2D
@export var _ScnBoosterListing: PackedScene

func _ready() -> void:
	FirebaseFirestoreDocument.connect("update_currency_done", Callable(self, "update_value"))
	GoogleIapModule.connect("update_diamond_value", Callable(self, "update_value"))


func _on_Shop_Page_visibility_changed():
	if visible:
		check_purchase_conditions()
		for child in get_node("ScrollContainer/VBoxContainer/BoosterContainer").get_children():
			child.queue_free()
		for b in Globals.BoosterAttributes:
			for i in range (1,4):
				if GameLoader.player_data["booster_parameters"][str(b)]["Discovered_Tier_" + str(i)] == 1:
					var listing = _ScnBoosterListing.instantiate()
					get_node("ScrollContainer/VBoxContainer/BoosterContainer").add_child(listing)
					listing.initialize_listing(Globals.BoosterAttributes[b], i)
					listing.connect("booster_purchase", Callable(self, "_on_booster_purchase"))
					self.connect("update_listings", Callable(listing, "_on_update_listings"))
		
		if get_node("ScrollContainer/VBoxContainer/BoosterContainer").get_child_count() == 0:
			print(get_node("ScrollContainer/VBoxContainer/BoosterContainer").get_child_count())
			get_node("ScrollContainer/VBoxContainer/TitleBar_(Booster)").hide()
		if get_node("ScrollContainer/VBoxContainer/BoosterContainer").get_child_count() != 0:
			print(get_node("ScrollContainer/VBoxContainer/BoosterContainer").get_child_count())
			get_node("ScrollContainer/VBoxContainer/TitleBar_(Booster)").show()
	else:
		GameLoader.save_game()


func _on_booster_purchase() -> void:
	emit_signal("update_listings")


func on_btn_buycoin (value: int) -> void:
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


func check_purchase_conditions() -> void:
	if GameLoader.load_currency("diamonds") >= 30:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem1/BuyButton.disabled = false
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem1/BuyButton/NinePatchRect.texture = enabled_toggle
	else:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem1/BuyButton.disabled = true
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem1/BuyButton/NinePatchRect.texture = disabled_toggle
		
	if GameLoader.load_currency("diamonds") >= 50:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem2/BuyButton.disabled = false
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem2/BuyButton/NinePatchRect.texture = enabled_toggle
	else:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem2/BuyButton.disabled = true
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem2/BuyButton/NinePatchRect.texture = disabled_toggle
		
	if GameLoader.load_currency("diamonds") >= 230:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem3/BuyButton.disabled = false
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem3/BuyButton/NinePatchRect.texture = enabled_toggle
	else:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem3/BuyButton.disabled = true
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem3/BuyButton/NinePatchRect.texture = disabled_toggle
		
	if GameLoader.load_currency("diamonds") >= 400:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem4/BuyButton.disabled = false
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem4/BuyButton/NinePatchRect.texture = enabled_toggle
	else:
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem4/BuyButton.disabled = true
		$ScrollContainer/VBoxContainer/GoldContainer/CoinsItem4/BuyButton/NinePatchRect.texture = disabled_toggle


func on_btn_buydiamond (value: int) -> void:
	match value:
		1:
			if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
				GoogleIapModule.on_purchase("inapp1")
			else:
				GameLoader.save_currency("diamonds", 50)
				update_value()
		2:
			if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
				GoogleIapModule.on_purchase("inapp2")
			else:
				GameLoader.save_currency("diamonds", 200)
				update_value()
		3:
			if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
				GoogleIapModule.on_purchase("inapp3")
			else:
				GameLoader.save_currency("diamonds", 600)
				update_value()
		4:
			if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
				GoogleIapModule.on_purchase("inapp4")
			else:
				GameLoader.save_currency("diamonds", 1200)
				update_value()


func update_value() -> void:
	if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
		send_page_update(FirebaseFirestoreDocument.player_document.coins, FirebaseFirestoreDocument.player_document.diamonds)
	else:
		send_page_update(GameLoader.load_currency("coins"), GameLoader.load_currency("diamonds"))


func close_page() -> void:
	return_page()


func update_text() -> void:
	if GoogleIapModule.purchasable_inapp.is_empty():
		pass
	else:
		$BottomPanel/VBoxContainer/DiamondContainer/DiamondsItem1/BuyButton.text = GoogleIapModule.purchasable_inapp["inapp1"].price
		$BottomPanel/VBoxContainer/DiamondContainer/DiamondsItem2/BuyButton.text = GoogleIapModule.purchasable_inapp["inapp2"].price
		$BottomPanel/VBoxContainer/DiamondContainer/DiamondsItem3/BuyButton.text = GoogleIapModule.purchasable_inapp["inapp3"].price
		$BottomPanel/VBoxContainer/DiamondContainer/DiamondsItem4/BuyButton.text = GoogleIapModule.purchasable_inapp["inapp4"].price


func _on_Shop_Page_draw() -> void:
	update_text()


func _on_Btn_RemoveAdMonthly_pressed():
	pass # Replace with function body.


func _on_Btn_RemoveAdYearly_pressed():
	pass # Replace with function body.
