@tool
## @meta-authors TODO
## @meta-version 1.1
## Firebase Dynamic Links for Godot 4

class_name FirebaseDynamicLinks
extends Node

signal dynamic_link_generated(link_result)

const _AUTHORIZATION_HEADER: String = "Authorization: Bearer "

var request: int = -1

var _dynamic_link_request_url: String = "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=%s"

var _config: Dictionary = {}
var _auth: Dictionary = {}

var _request_list_node: HTTPRequest
var _headers: PackedStringArray = ["Content-Type: application/json"]

enum Requests {
	NONE = -1,
	GENERATE
}

func _set_config(config_json: Dictionary) -> void:
	_config = config_json
	_dynamic_link_request_url = _dynamic_link_request_url % _config.apiKey

	_request_list_node = HTTPRequest.new()
	add_child(_request_list_node)

	_request_list_node.request_completed.connect(_on_request_completed)


var _link_request_body: Dictionary = {
	"dynamicLinkInfo": {
		"domainUriPrefix": "",
		"link": "",
		"androidInfo": {
			"androidPackageName": ""
		},
		"iosInfo": {
			"iosBundleId": ""
		}
	},
	"suffix": {
		"option": ""
	}
}


## @args long_link, APN, IBI, is_unguessable
## Generate Firebase Dynamic Link (REST API)
func generate_dynamic_link(long_link: String, APN: String, IBI: String, is_unguessable: bool) -> void:
	request = Requests.GENERATE

	_link_request_body["dynamicLinkInfo"]["domainUriPrefix"] = _config.domainUriPrefix
	_link_request_body["dynamicLinkInfo"]["link"] = long_link
	_link_request_body["dynamicLinkInfo"]["androidInfo"]["androidPackageName"] = APN
	_link_request_body["dynamicLinkInfo"]["iosInfo"]["iosBundleId"] = IBI

	# Correct ternary operator for Godot
	_link_request_body["suffix"]["option"] = "UNGUESSABLE" if is_unguessable else "SHORT"

	var json_body = JSON.stringify(_link_request_body).to_utf8_buffer()

	_request_list_node.request(
		_dynamic_link_request_url,
		_headers,
		HTTPClient.METHOD_POST,
		json_body
	)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json := JSON.new()
	var parse_result := json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		push_error("Firebase Dynamic Links: JSON parse failed: %s" % json.get_error_message())
		return

	var result_body: Dictionary = json.get_data()

	if result_body.has("shortLink"):
		emit_signal("dynamic_link_generated", result_body["shortLink"])
	else:
		push_error("Firebase Dynamic Links: Missing 'shortLink' in response: %s" % str(result_body))

	request = Requests.NONE


func _on_FirebaseAuth_login_succeeded(auth_result: Dictionary) -> void:
	_auth = auth_result

func _on_FirebaseAuth_token_refresh_succeeded(auth_result: Dictionary) -> void:
	_auth = auth_result

func _on_FirebaseAuth_logout() -> void:
	_auth = {}
