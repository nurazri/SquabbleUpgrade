extends Node

signal update_currency_done

var auth_value := {
	"googleId": "",
	"token": "",
	"id": "",
}

var player_document := {}


func _ready() -> void:
	_connect_signal()


func _connect_signal() -> void:
	# for Firebase login purpose
	# warning-ignore:return_value_discarded
	Firebase.Auth.connect("login_succeeded", Callable(self, "_on_FirebaseAuth_login_succeeded"))
	# warning-ignore:return_value_discarded
	Firebase.Auth.connect("login_failed", Callable(self, "_on_FirebaseAuth_login_failed"))
	# warning-ignore:return_value_discarded
	Firebase.Auth.connect("signup_succeeded", Callable(self, "_on_FirebaseAuth_create_succeeded"))
	
	# for Firebase Firestore purpose
	# warning-ignore:return_value_discarded
	Firebase.Firestore.collection("player_data").connect("add_document", Callable(self, "_on_add_document"))
	# warning-ignore:return_value_discarded
	Firebase.Firestore.collection("player_data").connect("get_document", Callable(self, "_on_get_document"))
	# warning-ignore:return_value_discarded
	Firebase.Firestore.collection("player_data").connect("update_document", Callable(self, "_on_update_document"))
	# warning-ignore:return_value_discarded
	Firebase.Firestore.collection("player_data").connect("delete_document", Callable(self, "_on_delete_document"))
	# warning-ignore:return_value_discarded
	Firebase.Firestore.collection("player_data").connect("error", Callable(self, "_on_document_error"))
	

# Part where collect authorization key for firebase
func get_user_info(auth : Dictionary) -> void:
	auth_value.token = auth.idtoken
	auth_value.id = auth.localid
	print("\n[FirebaseFirestoreDocument] Token:\n" + auth_value.token + "\n")
	print("[FirebaseFirestoreDocument] ID: " + auth_value.id)
	print("[FirebaseFirestoreDocument] Google ID: " + auth_value.googleId)


func get_request_headers() -> PackedStringArray:
	return PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % auth_value.token
	])


# Part where Firebase.Firestore create, load, update and delete document
func save_document_cloud(collectionID: String, documentID: String, fields: Dictionary) -> void:
	print("[FirebaseFirestoreDocument] Create " + documentID + " data")
	
	var add_task : FirestoreTask = Firebase.Firestore.collection(collectionID).add(documentID, fields)
	var document : FirestoreDocument = await add_task.add_document


func load_document_cloud(collectionID: String, documentID: String) -> void:
	print("[FirebaseFirestoreDocument] Load " + documentID + " data")
	
	var collection : FirestoreCollection =  Firebase.Firestore.collection(collectionID)
	var collection_task : FirestoreTask = collection.get(documentID)
	var document : FirestoreDocument = await collection_task.get_document
	
	collection.connect("get_document", Callable(self, "_on_get_document"))


func update_document_cloud(collectionID: String, documentID: String, fields: Dictionary) -> void:
	print("[FirebaseFirestoreDocument] Update " + documentID + " data")
	
	var update_task : FirestoreTask = Firebase.Firestore.collection(collectionID).update(documentID, fields)
	var document : FirestoreDocument = await update_task.update_document


func delete_document_cloud(collectionID: String, documentID: String) -> void:
	var del_task : FirestoreTask = Firebase.Firestore.collection(collectionID).delete(documentID)
	var document : FirestoreDocument = await del_task.delete_document


# Part where Firebase Auth return result
func _on_FirebaseAuth_create_succeeded(auth: Dictionary) -> void:
	print("[FirebaseFirestoreDocument] FirebaseAuth create succeeded")
	
	get_user_info(auth)
	print("[FirebaseFirestoreDocument] Create user document")
	
	GameLoader.load_logins()
#	if GameLoader.get_save_data("is_first_time"):
#		save_document_cloud("player_data", auth_value.googleId, GameLoader.default_player_document_data)
#	else:
#		load_document_cloud("player_data", auth_value.googleId)


func _on_FirebaseAuth_login_failed(code, message) -> void:
	print("[FirebaseFirestoreDocument] Firebase login failed")
	print("[FirebaseFirestoreDocument] Error code: " + str(code))
	print("[FirebaseFirestoreDocument] Error message: " + str(message))
	
	
func _on_add_document(document : FirestoreDocument) -> void:
	print ("[FirebaseFirestoreDocument] Succesfully added " + document.doc_name + " data")
	player_document = document.doc_fields
	print ("[FirebaseFirestoreDocument] " + str(player_document))
	

func _on_get_document(document : FirestoreDocument) -> void:
	print ("[FirebaseFirestoreDocument] Succesfully collected " + document.doc_name + " data")
	print ("[FirebaseFirestoreDocument] " + str(document))
	
	player_document = document.doc_fields
	emit_signal("update_currency_done")


func _on_update_document(document : FirestoreDocument) -> void:
	print ("[FirebaseFirestoreDocument] Succesfully updated " + document.doc_name + " data")
	print ("[FirebaseFirestoreDocument] " + str(document))
	
	player_document = document.doc_fields
	emit_signal("update_currency_done")


func _on_delete_document(document : FirestoreDocument) -> void:
	print ("[FirebaseFirestoreDocument] Succesfully delete " + document.doc_name + " data")
	print ("[FirebaseFirestoreDocument]" + str(document))


func _on_document_error(error : int, status: String, message: String) -> void:
	print ("[FirebaseFirestoreDocument] Error code: " + str(error))
	print ("[FirebaseFirestoreDocument] Error status: " + status)
	print ("[FirebaseFirestoreDocument] Error message: " + message)
