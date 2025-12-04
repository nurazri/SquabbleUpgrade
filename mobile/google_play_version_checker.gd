extends Control

@export var internal_release_url: String = "https://squabble-5848595-default-rtdb.firebaseio.com/internal_google_play_version_code.json"
@export var public_release_url: String = "https://squabble-5848595-default-rtdb.firebaseio.com/public_google_play_version_code.json"

var build_version_code: int = 0 # Do not change this value or even this line, it is used by GitHub Actions
								# The actual version code is read from the .version_code file and "injected"
								# here during the automated build. Yes if you export a build manually this 
								# will always be 0 and so there will always be a "new update available"


func _ready() -> void:
	$Confirmation.hide()

	var file: File = File.new()
	var error: int = file.open("res://.version_code", File.READ) # Does not work on Android
	if error == OK: # Will error out on Android, so on Android it depends on the automated build
					# to set the version code
		build_version_code = int(file.get_line())
	file.close()

	if OS.get_name() == "Android":
		print("Checking for updates...")
		$HTTPRequest.request(public_release_url)
		

func _on_HTTPRequest_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray) -> void:
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8()).result)
	var public_version_code: int = int(test_json_conv.get_data()
	
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

