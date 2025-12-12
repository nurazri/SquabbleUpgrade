extends Node

# SIGNALS
signal fb_inited
signal login_success(token)
signal login_cancelled
signal login_failed(error)
signal request_success(result)
signal request_cancelled
signal request_failed(error)
signal logout_signal

# VARIABLES
var _fb = null
var token = null
var user = null

# READY
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Engine.has_singleton("GodotFacebook"):  # Android
		_fb = Engine.get_singleton("GodotFacebook")
		_fb.setFacebookCallbackId(get_instance_id())
		print("Facebook plugin inited")
		emit_signal("fb_inited")

# LOGIN
func login(permissions = null):
	if _fb != null:
		if permissions == null:
			permissions = ["public_profile", "email", "user_friends"]
		_fb.login(permissions)
		return true
	return false

# GAME REQUESTS
func game_request(message, recipients = "", objectId = ""):
	if _fb != null:
		_fb.gameRequest(message, recipients, objectId)

func game_requests(object, method):
	if _fb != null:
		if OS.get_name() == "iOS":
			_fb.callApi("/me/apprequests", {}, object, method)
		else:
			_fb.callApi("/me/apprequests", {}, object.get_instance_id(), method)

# LOGOUT
func do_logout():
	if _fb != null:
		_fb.logout()
		emit_signal("logout_signal")

# STATUS
func is_logged_in():
	if _fb != null:
		return _fb.isLoggedIn()
	return false

# USER PROFILE
func user_profile(object, method):
	if _fb != null:
		var params = {"fields": "id,name,first_name,last_name,picture"}
		if OS.get_name() == "iOS":
			_fb.callApi("/me", params, object, method)
		else:
			_fb.callApi("/me", params, object.get_instance_id(), method)

# FRIENDS
func get_friends(object, method):
	if _fb != null:
		var params = {"fields": "name,first_name,last_name,picture", "limit": 3000}
		if OS.get_name() == "iOS":
			_fb.callApi("/me/friends", params, object, method)
		else:
			_fb.callApi("/me/friends", params, object.get_instance_id(), method)

func get_invitable_friends(object, method):
	if _fb != null:
		var params = {"fields": "first_name,last_name,picture", "limit": 3000}
		if OS.get_name() == "iOS":
			_fb.callApi("/me/invitable_friends", params, object, method)
		else:
			_fb.callApi("/me/invitable_friends", params, object.get_instance_id(), method)

# FB ANALYTICS
func set_push_token(push_token):
	if _fb != null:
		_fb.set_push_token(push_token)

func log_event(event, value = 0, params = null):
	if _fb != null:
		if value != 0 and params != null:
			_fb.log_event_value_params(event, value, params)
		elif value != 0:
			_fb.log_event_value(event, value)
		elif params != null:
			_fb.log_event_params(event, params)
		else:
			_fb.log_event(event)

func log_purchase(price, currency = "USD", params = null):
	if _fb != null:
		if params != null:
			_fb.log_purchase_params(price, currency, params)
		else:
			_fb.log_purchase(price, currency)

func deep_link_uri():
	if _fb != null:
		return _fb.deep_link_uri()
	return null

func deep_link_ref():
	if _fb != null:
		return _fb.deep_link_ref()
	return null

func deep_link_promo():
	if _fb != null:
		return _fb.deep_link_promo()
	return null

func set_advertiser_tracking(enabled: bool) -> void:
	if _fb != null and OS.get_name() == "iOS":
		_fb.setAdvertiserTracking(enabled)

# CALLBACKS - RENAMED TO AVOID SIGNAL CONFLICTS
func on_login_success(tkn):
	token = tkn
	print("Facebook login success: %s" % tkn)
	emit_signal("login_success", tkn)

func on_login_cancelled():
	token = null
	user = null
	print("Facebook login canceled")
	emit_signal("login_cancelled")

func on_login_failed(error_msg):
	token = null
	user = null
	print("Facebook login failed: %s" % error_msg)
	emit_signal("login_failed", error_msg)

func on_request_success(result):
	emit_signal("request_success", result)

func on_request_cancelled():
	push_warning("Facebook request canceled")
	emit_signal("request_cancelled")

func on_request_failed(err):
	push_error("Facebook request failed: %s" % var_to_str(err))
	emit_signal("request_failed", err)
