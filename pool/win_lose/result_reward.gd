extends Control

var _already_init: bool = false
var _amount: int = 0
var _type: int = 0
var _extra: Dictionary = {}

func init(amount: int, type: int, extra: Dictionary = {}) -> void:
	if not _already_init:
		_already_init = true
		match type:
			1:  #For Booster
				$RewardTexture.texture = Globals.BoosterAttributes[int(extra["type"])].Info.Tier[int(extra["tier"])]
				
			2:  #For Coin, temp method
				if amount >= 75:
					$RewardTexture.texture = Globals.CoinTexture["Tier_4"]
				elif amount > 50:
					$RewardTexture.texture = Globals.CoinTexture["Tier_3"]
				elif amount >= 25:
					$RewardTexture.texture = Globals.CoinTexture["Tier_2"]
				elif amount >= 0:
					$RewardTexture.texture = Globals.CoinTexture["Tier_1"]
			
			3: #For Gem
				$RewardTexture.texture = Globals.DiamondTexture["Tier_1"] 
		
		$RewardTexture/LabelAmount.text = str(amount)
		_amount = amount
		_type = type
		_extra = extra


func reinit() -> void:
	$RewardTexture/LabelAmount.text = str((_amount * 2))


func _double_reward() -> void:
	$RewardTexture/LabelAmount.text = str(_amount * 2)
	if _type == 2:
		GameLoader.save_currency("coins", _amount)
		if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
			FirebaseFirestoreDocument.player_document.coins += _amount
			FirebaseFirestoreDocument.update_document_cloud("player_data", FirebaseFirestoreDocument.auth_value.googleId, FirebaseFirestoreDocument.player_document)
	if _type == 3:
		GameLoader.save_currency("diamonds", _amount)
		if !FirebaseFirestoreDocument.auth_value.googleId.is_empty():
			FirebaseFirestoreDocument.player_document.diamonds += _amount
			FirebaseFirestoreDocument.update_document_cloud("player_data", FirebaseFirestoreDocument.auth_value.googleId, FirebaseFirestoreDocument.player_document)
