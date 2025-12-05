@tool
## @meta-authors TODO
## @meta-version 2.3
## Firebase Authentication for Godot 4
class_name FirebaseAuth
extends HTTPRequest

signal signup_succeeded(auth_result)
signal login_succeeded(auth_result)
signal login_failed(code, message)
signal userdata_received(userdata)
signal token_exchanged(successful)
signal token_refresh_succeeded(auth_result)
signal logged_out()

# ----------------- Constants -----------------
const RESPONSE_SIGNUP : String   = "identitytoolkit#SignupNewUserResponse"
const RESPONSE_SIGNIN : String   = "identitytoolkit#VerifyPasswordResponse"
const RESPONSE_ASSERTION : String  = "identitytoolkit#VerifyAssertionResponse"
const RESPONSE_USERDATA : String = "identitytoolkit#GetAccountInfoResponse"

# Firebase API URLs
var _signup_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"
var _signin_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"
var _signin_with_oauth_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=%s"
var _userdata_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=%s"
var _refresh_request_url : String = "https://securetoken.googleapis.com/v1/token?key=%s"
var _oobcode_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s"
var _delete_account_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=%s"
var _update_account_request_url : String = "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s"

# ----------------- Variables -----------------
var _config : Dictionary = {}
var auth : Dictionary = {}
var _needs_refresh : bool = false
var is_busy : bool = false

var _headers : PackedStringArray = ["Accept: application/json"]
var requesting : int = -1

enum Requests { NONE = -1, EXCHANGE_TOKEN, LOGIN_WITH_OAUTH }

var _login_request_body : Dictionary = { "email":"", "password":"", "returnSecureToken": true }
var _anonymous_login_request_body : Dictionary = { "returnSecureToken": true }
var _oauth_login_request_body : Dictionary = { "postBody":"", "requestUri":"", "returnIdpCredential":true, "returnSecureToken":true }
var _refresh_request_body : Dictionary = { "grant_type":"refresh_token", "refresh_token":"" }
var _password_reset_body : Dictionary = { "requestType":"password_reset", "email":"" }
var _change_email_body : Dictionary = { "idToken":"", "email":"", "returnSecureToken": true }
var _change_password_body : Dictionary = { "idToken":"", "password":"", "returnSecureToken": true }
var _account_verification_body : Dictionary = { "requestType":"verify_email", "idToken":"" }
var _update_profile_body : Dictionary = { "idToken":"", "displayName":"", "photoUrl":"", "deleteAttribute":"", "returnSecureToken":true }
var _post_body : String = "id_token=[GOOGLE_ID_TOKEN]&providerId=[PROVIDER_ID]"
var _request_uri : String = "[REQUEST_URI]"

# ----------------- Config -----------------
func _set_config(config_json : Dictionary) -> void:
	_config = config_json
	_signup_request_url %= _config.apiKey
	_signin_request_url %= _config.apiKey
	_signin_with_oauth_request_url %= _config.apiKey
	_userdata_request_url %= _config.apiKey
	_refresh_request_url %= _config.apiKey
	_oobcode_request_url %= _config.apiKey
	_delete_account_request_url %= _config.apiKey
	_update_account_request_url %= _config.apiKey
	connect("request_completed", Callable(self, "_on_FirebaseAuth_request_completed"))

# ----------------- Helper for Godot 4 -----------------
func _send_request(url: String, body: Dictionary, method: int = HTTPClient.METHOD_POST) -> void:
	request(url, _headers, method, JSON.stringify(body))


func _is_ready() -> bool:
	if is_busy:
		printerr("Firebase Auth is currently busy")
		return false
	return true

# ----------------- Auth Functions -----------------
func signup_with_email_and_password(email: String, password: String) -> void:
	if not _is_ready():
		return
	is_busy = true
	_login_request_body.email = email
	_login_request_body.password = password
	_send_request(_signup_request_url, _login_request_body)

func login_with_email_and_password(email: String, password: String) -> void:
	if not _is_ready():
		return
	is_busy = true
	_login_request_body.email = email
	_login_request_body.password = password
	_send_request(_signin_request_url, _login_request_body)

func login_anonymous() -> void:
	if not _is_ready():
		return
	is_busy = true
	_send_request(_signup_request_url, _anonymous_login_request_body)

func change_user_email(email: String) -> void:
	if not _is_ready():
		return
	is_busy = true
	_change_email_body.email = email
	_change_email_body.idToken = auth.idtoken
	_send_request(_update_account_request_url, _change_email_body)

func change_user_password(password: String) -> void:
	if not _is_ready():
		return
	is_busy = true
	_change_password_body.password = password
	_change_password_body.idToken = auth.idtoken
	_send_request(_update_account_request_url, _change_password_body)

func send_password_reset_email(email: String) -> void:
	if not _is_ready():
		return
	is_busy = true
	_password_reset_body.email = email
	_send_request(_oobcode_request_url, _password_reset_body)

func send_account_verification_email() -> void:
	if not _is_ready():
		return
	is_busy = true
	_account_verification_body.idToken = auth.idtoken
	_send_request(_oobcode_request_url, _account_verification_body)

func get_user_data() -> void:
	if not _is_ready():
		return
	if auth == null or not auth.has("idtoken"):
		print_debug("Not logged in")
		is_busy = false
		return
	_send_request(_userdata_request_url, {"idToken": auth.idtoken})

func delete_user_account() -> void:
	if not _is_ready():
		return
	is_busy = true
	_send_request(_delete_account_request_url, {"idToken": auth.idtoken})

# ----------------- Token Refresh -----------------
func manual_token_refresh(auth_data: Dictionary) -> void:
	auth = get_clean_keys(auth_data)
	var refresh_token = ""
	if auth.has("refreshtoken"):
		refresh_token = auth.refreshtoken
	elif auth.has("refresh_token"):
		refresh_token = auth.refresh_token
	_needs_refresh = true
	_refresh_request_body.refresh_token = refresh_token
	_send_request(_refresh_request_url, _refresh_request_body)

func begin_refresh_countdown() -> void:
	var refresh_token = ""
	var expires_in = 1000
	if auth.has("refreshtoken"):
		refresh_token = auth.refreshtoken
		expires_in = auth.expiresin
	elif auth.has("refresh_token"):
		refresh_token = auth.refresh_token
		expires_in = auth.expires_in
	_needs_refresh = true
	emit_signal("token_refresh_succeeded", auth)
	await get_tree().create_timer(float(expires_in)).timeout
	_refresh_request_body.refresh_token = refresh_token
	_send_request(_refresh_request_url, _refresh_request_body)

# ----------------- Utility -----------------
func get_clean_keys(auth_result: Dictionary) -> Dictionary:
	var cleaned = {}
	for key in auth_result.keys():
		cleaned[key.replace("_","").to_lower()] = auth_result[key]
	return cleaned
