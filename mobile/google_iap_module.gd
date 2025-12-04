extends Node

var payment
const item_sku:Array = ["inapp1", "inapp2", "inapp3", "inapp4"]
var purchasable_inapp: Dictionary
var test_item_purchase_token = null
var purchased_sku: String

signal update_diamond_value


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		print("Android IAP support works")
		# These are all signals supported by the API
		# You can drop some of these based on your needs
		payment.connect("connected", Callable(self, "_on_connected")) # No params
		payment.connect("disconnected", Callable(self, "_on_disconnected")) # No params
		payment.connect("connect_error", Callable(self, "_on_connect_error")) # Response ID (int), Debug message (string)
		payment.connect("purchases_updated", Callable(self, "_on_purchases_updated")) # Purchases (Dictionary[])
		payment.connect("purchase_error", Callable(self, "_on_purchase_error")) # Response ID (int), Debug message (string)
		payment.connect("sku_details_query_completed", Callable(self, "_on_sku_details_query_completed")) # SKUs (Dictionary[])
		payment.connect("sku_details_query_error", Callable(self, "_on_sku_details_query_error")) # Response ID (int), Debug message (string), Queried SKUs (string[])
		payment.connect("purchase_acknowledged", Callable(self, "_on_purchase_acknowledged")) # Purchase token (string)
		payment.connect("purchase_acknowledgement_error", Callable(self, "_on_purchase_acknowledgement_error")) # Response ID (int), Debug message (string), Purchase token (string)
		payment.connect("purchase_consumed", Callable(self, "_on_purchase_consumed")) # Purchase token (string)
		payment.connect("purchase_consumption_error", Callable(self, "_on_purchase_consumption_error")) # Response ID (int), Debug message (string), Purchase token (string)
		
		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")


func _on_connected():
	print ("Iap Function connected")
	payment.querySkuDetails(item_sku, "inapp")


func _on_sku_details_query_completed(sku_details):
	print("SKU details query completed, showing SKU now")
	for available_sku in sku_details:
		purchasable_inapp[available_sku.sku] = available_sku
		print (available_sku)
	
	print ("Getting Query Purchases")
	var query_iap = payment.queryPurchases("inapp")
	print (query_iap)
	
	if query_iap.status == OK:
		for purchase in query_iap.purchases:
			if !purchase.is_acknowledged:
				print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
				payment.consumePurchase(purchase.purchase_token)
	else:
		print("Purchase query failed: %d" % query_iap.status)


func _on_purchase_acknowledged(purchase_token):
	print("Purchase acknowledged: %s" % purchase_token)


func _on_purchases_updated(purchases):
	print("Purchase updated: %s" % JSON.new().stringify(purchases))
	
	# See _on_connected
	for purchase in purchases:
		if !purchase.is_acknowledged:
			print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
			purchased_sku = purchase.sku
			payment.consumePurchase(purchase.purchase_token)

	if purchases.size() > 0:
		test_item_purchase_token = purchases[purchases.size() - 1].purchase_token


func _on_purchase_consumed(purchase_token):
	print("Purchase consumed successfully: %s" % purchase_token)
	
	match purchased_sku:
		"inapp1":
			FirebaseFirestoreDocument.player_document.diamonds += 50
			FirebaseFirestoreDocument.update_document_cloud("player_data", FirebaseFirestoreDocument.auth_value.googleId, FirebaseFirestoreDocument.player_document)
		"inapp2":
			FirebaseFirestoreDocument.player_document.diamonds += 200
			FirebaseFirestoreDocument.update_document_cloud("player_data", FirebaseFirestoreDocument.auth_value.googleId, FirebaseFirestoreDocument.player_document)
		"inapp3":
			FirebaseFirestoreDocument.player_document.diamonds += 600
			FirebaseFirestoreDocument.update_document_cloud("player_data", FirebaseFirestoreDocument.auth_value.googleId, FirebaseFirestoreDocument.player_document)
		"inapp4":
			FirebaseFirestoreDocument.player_document.diamonds += 1200
			FirebaseFirestoreDocument.update_document_cloud("player_data", FirebaseFirestoreDocument.auth_value.googleId, FirebaseFirestoreDocument.player_document)
			
	
	emit_signal("update_diamond_value")


func _on_purchase_error(code, message):
	print("Purchase error %d: %s" % [code, message])


func _on_purchase_acknowledgement_error(code, message):
	print("Purchase acknowledgement error %d: %s" % [code, message])


func _on_purchase_consumption_error(code, message, purchase_token):
	print("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


func _on_sku_details_query_error(code, message):
	print("SKU details query error %d: %s" % [code, message])


func _on_disconnected():
	print("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	await get_tree().create_timer(10).timeout
	payment.startConnection()


func on_purchase(productID: String):
	payment.purchase(productID)
