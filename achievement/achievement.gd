extends Control

signal reward_claimed

@export var _GreyedOutStar: Texture2D
@export var _LightupStar: Texture2D
@export var _GreyedOutBox: Texture2D
@export var _ReadyClaimBox: Texture2D

var progress_step: String = "Panel/ProgressBar/Step_"

var _loaded_achievements: Dictionary = {}
var _can_claim = [false, false, false]
var _achievement_id: String

func init(_achievement_data: Dictionary, id: String) -> void:
	_loaded_achievements = _achievement_data
	_achievement_id = id
	
	var _avatar_texture: Texture2D = Globals.AvatarTextures[int(_achievement_data["rewardamount"]["3"])]
	var _avatar_texture_locked: Texture2D = Globals.AvatarLockedTextures[int(_achievement_data["rewardamount"]["3"])]
	var currently_at: int = 0
	
	$Panel/Description.text = "[" + str(_achievement_data["trophy_title"]) + "]\n" + str(_achievement_data["trophy_description"]) 
	$Panel/AvatarUnlock.texture = _avatar_texture_locked
	$Panel/ProgressBar/Step_3/Rewardtype.texture = _avatar_texture_locked
	
	for i in range(1,4):
		if _achievement_data["rewardtype"][str(i)] != "none":
			get_node(progress_step + str(i) + "/Star/Condition").text = str(_achievement_data["requirement"][str(i)])
			get_node(progress_step + str(i) + "/Rewardtype/Amount").text = str(_achievement_data["rewardamount"][str(i)])
			if _achievement_data["points"] >= _achievement_data["requirement"][str(i)]:
				currently_at = i
				$Panel/ProgressBar.value = 33 * i
				get_node(progress_step + str(i) + "/Star").texture = _LightupStar
				get_node("Panel/Rating/" + str(i) + "Star").texture = _LightupStar
				
				if _achievement_data["rewardstatus"][str(i)] == 0:
					set_button_claim_status("Ready Claim")
					_can_claim[i - 1] = true
				else:
					set_button_claim_status("No Claim")
					get_node(progress_step + str(i) + "/Rewardtype/Amount/Checked").show()
		else:
			get_node(progress_step + str(i)).hide()
	
	if currently_at < 3:
		$Panel/ProgressTracker.text = str(_achievement_data["points"]) + "/" + str(_achievement_data["requirement"][str(currently_at + 1)])
	else:
		$Panel/ProgressTracker.text = str(_achievement_data["points"]) + "/" + str(_achievement_data["requirement"][str(currently_at)])
		
	if _achievement_data["rewardstatus"]["3"] == 1:
		set_button_claim_status("Finish Claim")
		$Panel/AvatarUnlock.texture = _avatar_texture
		$Panel/ProgressBar/Step_3/Rewardtype.texture = _avatar_texture
		$Panel/ProgressBar/Step_3/Rewardtype.modulate.a = 1


func set_button_claim_status(type) -> void:
	match type:
		"Ready Claim":
			$Panel/BtnParent.set_texture(_ReadyClaimBox)
			$Panel/BtnParent/BtnClaimed.disabled = false
		"No Claim":
			$Panel/BtnParent.set_texture(_GreyedOutBox)
			$Panel/BtnParent/BtnClaimed.disabled = true
		"Finish Claim":
			$Panel/BtnParent.hide()
			$Panel/Claimed.show()


func _on_BtnClaimed_pressed() -> void:
	for claimable in _can_claim.size():
		var step = claimable + 1
		if _can_claim[claimable] == true:
			GameLoader.update_achievement_reward_status(_achievement_id, "rewardstatus", str(step),1)
			get_node(progress_step + str(step) + "/Rewardtype/Amount/Checked").show()
			get_node("Panel/Rating/" + str(step) + "Star").texture = _LightupStar
		
		if step == 3:
			set_button_claim_status("Finish Claim")
		
	set_button_claim_status("No Claim")
	GameLoader.overwrite_achievement_value()
	emit_signal("reward_claimed", GameLoader.default_player_document_data["coins"], GameLoader.default_player_document_data["diamonds"])
	

# Mainly for debugging purposes, will be removed in the future
func _on_Achievement_Page_reset_progress() -> void:
	$Panel/BtnParent.show()
	$Panel/Claimed.hide()
	set_button_claim_status("No Claim")
	
	$Panel/ProgressBar.value = 0
	$Panel/ProgressBar/Step_3/Rewardtype.texture = Globals.AvatarLockedTextures[int(_loaded_achievements["rewardtype"]["3"])]
	$Panel/ProgressBar/Step_3/Rewardtype.modulate.a = 0.4
	$Panel/AvatarUnlock.texture = Globals.AvatarLockedTextures[int(_loaded_achievements["rewardamount"]["3"])]
	$Panel/ProgressTracker.text = str("0/" + str(_loaded_achievements["requirement"]["1"]))
	for i in range(1,4) :
		get_node("Panel/Rating/" + str(i) + "Star").texture = _GreyedOutStar
		get_node(progress_step + str(i) + "/Star").texture = _GreyedOutStar
		get_node(progress_step + str(i) + "/Rewardtype/Amount/Checked").hide()

