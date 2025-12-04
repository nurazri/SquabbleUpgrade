extends Control

var in_app_review


func _ready():
	if Engine.has_singleton("GodotGooglePlayInAppReview"):
		in_app_review = Engine.get_singleton("GodotGooglePlayInAppReview")
		in_app_review.connect("on_request_review_success", Callable(self, "_on_request_review_success"))
		in_app_review.connect("on_request_review_failed", Callable(self, "_on_request_review_failed"))
		in_app_review.connect("on_launch_review_flow_success", Callable(self, "_on_launch_review_flow_success"))


func _on_request_review_success() -> void:
	print("[GooglePlayInAppReview]: Request succeded!")
	in_app_review.launchReviewFlow()


func _on_request_review_failed() -> void:
	print("[GooglePlayInAppReview]: Request failed!")


func _on_launch_review_flow_success() -> void:
	print("[GooglePlayInAppReview]: Launched review flow!")


func _on_Button_pressed() -> void:
	if in_app_review:
		print("[GooglePlayInAppReview]: Requesting review info...")
		in_app_review.requestReviewInfo()

