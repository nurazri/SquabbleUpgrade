extends Node

enum AdType {
  INTERSTITIAL = 1,
  BANNER_TOP = 2,
  BANNER_BOTTOM = 4,
  REWARDED_VIDEO = 8,
}

signal consent_form_loaded()
signal consent_form_opened()
signal consent_form_dismissed()
signal consent_form_load_failure(error_message)

signal interstitial_failed_to_load()
signal interstitial_loaded()
signal interstitial_failed_to_show()
signal interstitial_opened()
signal interstitial_closed()

signal rewarded_ad_failed_to_load()
signal rewarded_ad_loaded()
signal rewarded_ad_failed_to_show()
signal rewarded_ad_opened()
signal rewarded_ad_closed(finished)
signal rewarded_ad_finished(amount, currency)

var _appodeal
var _apiKey


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.has_singleton("GodotAppodeal"):
		_appodeal = Engine.get_singleton("GodotAppodeal")
		if ProjectSettings.has_setting('Appodeal/AppKey'):
			_apiKey = ProjectSettings.get_setting('Appodeal/AppKey')

			_appodeal.connect("consent_form_loaded", Callable(self, "_on_Appodeal_consent_form_loaded"))
			_appodeal.connect("consent_form_shown", Callable(self, "_on_Appodeal_consent_form_shown"))
			_appodeal.connect("consent_form_load_failed", Callable(self, "_on_Appodeal_consent_form_load_failed"))
			_appodeal.connect("consent_form_closed", Callable(self, "_on_Appodeal_consent_form_closed"))

			_appodeal.connect("interstitial_loaded", Callable(self, "_on_Appodeal_interstitial_loaded"))
			_appodeal.connect("interstitial_load_failed", Callable(self, "_on_Appodeal_interstitial_load_failed"))
			_appodeal.connect("interstitial_shown", Callable(self, "_on_Appodeal_interstitial_shown"))
			_appodeal.connect("interstitial_show_failed", Callable(self, "_on_Appodeal_interstitial_show_failed"))
			_appodeal.connect("interstitial_closed", Callable(self, "_on_Appodeal_interstitial_closed"))

			_appodeal.connect("rewarded_video_loaded", Callable(self, "_on_Appodeal_rewarded_video_loaded"))
			_appodeal.connect("rewarded_video_load_failed", Callable(self, "_on_Appodeal_rewarded_video_load_failed"))
			_appodeal.connect("rewarded_video_shown", Callable(self, "_on_Appodeal_rewarded_video_shown"))
			_appodeal.connect("rewarded_video_show_failed", Callable(self, "_on_Appodeal_rewarded_video_show_failed"))
			_appodeal.connect("rewarded_video_closed", Callable(self, "_on_Appodeal_rewarded_video_closed"))
			_appodeal.connect("rewarded_video_finished", Callable(self, "_on_Appodeal_rewarded_video_finished"))


func set_testing_enabled(enabled: bool = true) -> void:
	if _appodeal:
		_appodeal.setTestingEnabled(enabled)


func show_consent_form() -> bool:
	if _appodeal:
		_appodeal.showConsentForm()
		return true
	return false


func load_ad(ad_type: int) -> bool:
	if _appodeal and _apiKey:
		_appodeal.initialize(_apiKey, ad_type)
		return true
	return false


func show_ad(ad_type: int) -> void:
	_appodeal.showAd(ad_type)


func is_ad_loaded(ad_type: int) -> bool:
	var is_mobile_device: bool = OS.get_name() == "Android" or OS.get_name() == "iOS"
	return is_mobile_device and _appodeal.isInitializedForAdType(ad_type)


func _on_Appodeal_consent_form_loaded() -> void:
	emit_signal("consent_form_loaded")


func _on_Appodeal_consent_form_shown() -> void:
	emit_signal("consent_form_opened")


func _on_Appodeal_consent_form_load_failed(error: String) -> void:
	emit_signal("consent_form_load_failure", error)


func _on_Appodeal_consent_form_closed() -> void:
	emit_signal("consent_form_dismissed")


func _on_Appodeal_interstitial_loaded(_precached) -> void:
	print("[Appodeal] Interstitial loaded")
	emit_signal("interstitial_loaded")


func _on_Appodeal_interstitial_load_failed() -> void:
	print("[Appodeal] Interstitial failed to load")
	emit_signal("interstitial_failed_to_load")


func _on_Appodeal_interstitial_shown() -> void:
	print("[Appodeal] Interstitial opened")
	emit_signal("interstitial_opened")


func _on_Appodeal_interstitial_show_failed() -> void:
	print("[Appodeal] Interstitial failed to show")
	emit_signal("interstitial_failed_to_show")


func _on_Appodeal_interstitial_closed() -> void:
	print("[Appodeal] Interstitial closed")
	emit_signal("interstitial_closed")


func _on_Appodeal_rewarded_video_loaded(_precached) -> void:
	print("[Appodeal] Rewarded ad loaded")
	emit_signal("rewarded_ad_loaded")


func _on_Appodeal_rewarded_video_load_failed() -> void:
	print("[Appodeal] Rewarded ad failed to load ")
	emit_signal("rewarded_ad_failed_to_load")


func _on_Appodeal_rewarded_video_shown() -> void:
	print("[Appodeal] Rewarded ad opened")
	emit_signal("rewarded_ad_opened")


func _on_Appodeal_rewarded_video_show_failed() -> void:
	print("[Appodeal] Rewarded ad failed to show")
	emit_signal("rewarded_ad_failed_to_show")


func _on_Appodeal_rewarded_video_closed(_finished: bool) -> void:
	print("[Appodeal] Rewarded ad closed")
	emit_signal("rewarded_ad_closed", _finished)


func _on_Appodeal_rewarded_video_finished(amount: float, currency: String) -> void:
	print("[Appodeal] Rewarded ad finished")
	emit_signal("rewarded_ad_finished", amount, currency)

