extends Control

signal booster_purchase

@export var enabled_toggle: Texture2D
@export var disabled_toggle: Texture2D

@export var coin_texture: Texture2D
@export var diamond_texture: Texture2D


var current_booster: Dictionary
var booster_level
var booster_cost: int = 0
var purchase_type: String = "None"

# Called when the node enters the scene tree for the first time.
func initialize_listing(_booster, _type):
	var booster_ref = _booster["Info"]["Ref_ID"]
	var booster_amount = GameLoader.player_data["booster_owned"][str(booster_ref)][str(_type)]
	current_booster = _booster
	booster_level = _type
	
	$BoosterType.text = _booster["Info"]["Class"][_type] + " " + _booster["Info"]["Name"]
	$Description.text = _booster["Info"]["Details"][_type]
	$Icon_Amount/Label.text = str(booster_amount)
	$Btn_BuyBooster/Label.text = str(_booster["Info"]["Cost"][_type])
	booster_cost = _booster["Info"]["Cost"][_type]
	purchase_type = _booster["Info"]["Cost_Type"][_type]
	
	if _booster["Info"]["Cost_Type"][_type] == "coins":
		$Btn_BuyBooster/Label/Currency.texture = coin_texture
	if _booster["Info"]["Cost_Type"][_type] == "diamonds":
		$Btn_BuyBooster/Label/Currency.texture = diamond_texture
	
	$Booster_Image.texture = _booster["Info"]["Tier"][_type]
	set_purchase_state()


func _on_update_listings() -> void:
	set_purchase_state()


func set_purchase_state() -> void:
	if purchase_type == "coins":
		if GameLoader.load_currency("coins") < booster_cost:
			$Btn_BuyBooster.disabled = true
			$Btn_BuyBooster/NinePatchRect.texture = disabled_toggle
		if GameLoader.load_currency("coins") >= booster_cost:
			$Btn_BuyBooster.disabled = false
			$Btn_BuyBooster/NinePatchRect.texture = enabled_toggle
	if purchase_type == "diamonds":
		if GameLoader.load_currency("diamonds") < booster_cost:
			$Btn_BuyBooster.disabled = true
			$Btn_BuyBooster/NinePatchRect.texture = disabled_toggle
		if GameLoader.load_currency("diamonds") >= booster_cost:
			$Btn_BuyBooster.disabled = false
			$Btn_BuyBooster/NinePatchRect.texture = enabled_toggle


#temporary method
func _on_Btn_BuyBooster_pressed():
	var booster_ref = current_booster["Info"]["Ref_ID"]
	GameLoader.save_currency(purchase_type, -(booster_cost))
	GameLoader.player_data["booster_owned"][str(booster_ref)][str(booster_level)] += 1
	$Icon_Amount/Label.text = str(GameLoader.player_data["booster_owned"][str(booster_ref)][str(booster_level)])
	
	emit_signal("booster_purchase")
