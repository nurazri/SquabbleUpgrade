extends Control

@export var internal_release_url: String = "https://squabble-5848595-default-rtdb.firebaseio.com/internal_google_play_version_code.json"
@export var public_release_url: String = "https://squabble-5848595-default-rtdb.firebaseio.com/public_google_play_version_code.json"

var build_version_code: int = 0 # Do not change this value; used by GitHub Actions


func _ready() -> void:
	$Confirmation.hide()

	# Reading version code from file (works outside Android)
	var file_error: int = OK
	if FileAccess.file_exists("res://.version_code"):
		var file: FileAccess = FileAccess.open("res://.version_code", FileAccess.READ)
		if file:
			build_version_code = int(file.get_line())
			file.close()
		else:
			file_error = ERR_CANT_OPEN
	else:
		file_error = ERR_DOES_NOT_EXIST

	if file_error != OK:
		print("Could not read version code from file. Using default build_version_code = 0")

	if OS.get_name() == "Android":
		print("Checking for updates...")
		$HTTPRequest.request(public_release_url)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json_parser := JSON.new()
	var error: int = json_parser.parse(body.get_string_from_utf8())
	if error != OK:
		print("Failed to parse JSON from update check!")
		return

	var public_version_code: int = int(json_parser.get_data())
	
	print("Latest Google Play public version code is: " + str(public_version_code))
	print("This build's version code is: " + str(build_version_code))

	if public_version_code > build_version_code:
		print("Google Play update available!")
		$Confirmation.show()


func _on_Yes_pressed() -> void:
	$Confirmation.hide()
	OS.shell_open("https://play.google.com/store/apps/details?id=my.gameka.Squabble")


func _on_No_pressed() -> void:
	$Confirmation.hide()


func _on_Confirmation_visibility_changed() -> void:
	visible = $Confirmation.visible
