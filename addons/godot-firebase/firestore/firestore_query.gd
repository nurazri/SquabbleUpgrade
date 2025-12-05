@tool
extends RefCounted
class_name FirestoreQuery

# ----------------- Inner Classes -----------------

class Order:
	var obj: Dictionary = {}

class Cursor:
	var values: Array[Variant] = []
	var before: bool = false

	func _init(v: Array[Variant], b: bool) -> void:
		values = v
		before = b

# ----------------- Signals -----------------
signal query_result(query_result)

# ----------------- Constants -----------------
const TEMPLATE_QUERY: Dictionary = {
	"select": {},
	"from": [],
	"where": {},
	"orderBy": [],
	"startAt": {},
	"endAt": {},
	"offset": 0,
	"limit": 0
}

# ----------------- Variables -----------------
var query: Dictionary = {}

enum OPERATOR {
	OPERATOR_NSPECIFIED,
	LESS_THAN,
	LESS_THAN_OR_EQUAL,
	GREATER_THAN,
	GREATER_THAN_OR_EQUAL,
	EQUAL,
	NOT_EQUAL,
	ARRAY_CONTAINS,
	ARRAY_CONTAINS_ANY,
	IN,
	NOT_IN,
	IS_NAN,
	IS_NULL,
	IS_NOT_NAN,
	IS_NOT_NULL,
	AND,
	OR
}

enum DIRECTION {
	DIRECTION_UNSPECIFIED,
	ASCENDING,
	DESCENDING
}

# ----------------- Initialization -----------------
func _init() -> void:
	query = TEMPLATE_QUERY.duplicate(true)

# ----------------- Query Builders -----------------
func select(fields: Variant) -> FirestoreQuery:
	match typeof(fields):
		TYPE_STRING:
			query["select"] = {"fields": [{"fieldPath": fields}]}
		TYPE_ARRAY:
			var f_arr: Array[Dictionary] = []
			for field in fields:
				f_arr.append({"fieldPath": field})
			query["select"] = {"fields": f_arr}
		_:
			printerr("Type of 'fields' is not accepted.")
	return self

func from(collection_id: String, all_descendants: bool = true) -> FirestoreQuery:
	query["from"] = [{"collectionId": collection_id, "allDescendants": all_descendants}]
	return self

func from_many(collections_array: Array) -> FirestoreQuery:
	var collections: Array[Dictionary] = []
	for c in collections_array:
		collections.append({"collectionId": c[0], "allDescendants": c[1]})
	query["from"] = collections.duplicate(true)
	return self

func where(field: String, operator: int, value: Variant = null, chain: int = -1) -> FirestoreQuery:
	var new_filter: Dictionary
	if operator in [OPERATOR.IS_NAN, OPERATOR.IS_NULL, OPERATOR.IS_NOT_NAN, OPERATOR.IS_NOT_NULL]:
		new_filter = create_unary_filter(field, operator)
	else:
		if value == null:
			printerr("A value must be defined for field: %s" % field)
			return self
		new_filter = create_field_filter(field, operator, value)

	var filters: Array[Dictionary] = []

	# Compose filters if chain operator exists
	if query.has("where") and query.where.has("compositeFilter"):
		filters = query.where.compositeFilter.filters.duplicate(true)
		filters.append(new_filter)
		query["where"] = create_composite_filter(chain, filters)
	elif chain in [OPERATOR.AND, OPERATOR.OR]:
		filters.append(new_filter)
		query["where"] = create_composite_filter(chain, filters)
	else:
		query["where"] = new_filter

	return self

func order_by(field: String, direction: int = DIRECTION.ASCENDING) -> FirestoreQuery:
	query["orderBy"] = [_order_object(field, direction).obj]
	return self

func order_by_fields(order_field_list: Array) -> FirestoreQuery:
	var order_list: Array[Dictionary] = []
	for order in order_field_list:
		if order is Array:
			order_list.append(_order_object(order[0], order[1]).obj)
		elif order is Order:
			order_list.append(order.obj)
	query["orderBy"] = order_list
	return self

func start_at(value: Variant, before: bool) -> FirestoreQuery:
	var cursor: Cursor = _cursor_object(value, before)
	query["startAt"] = {"values": cursor.values, "before": cursor.before}
	return self

func end_at(value: Variant, before: bool) -> FirestoreQuery:
	var cursor: Cursor = _cursor_object(value, before)
	query["endAt"] = {"values": cursor.values, "before": cursor.before}
	return self

func offset(offset_val: int) -> FirestoreQuery:
	if offset_val < 0:
		printerr("Offset must be >= 0")
	else:
		query["offset"] = offset_val
	return self

func limit(limit_val: int) -> FirestoreQuery:
	if limit_val < 0:
		printerr("Limit must be >= 0")
	else:
		query["limit"] = limit_val
	return self

# ----------------- Utilities -----------------
static func _cursor_object(value: Variant, before: bool) -> Cursor:
	var parse: Dictionary = FirestoreDocument.dict2fields({"value": value}).fields.value
	var values_array: Array[Variant] = parse.arrayValue.values if parse.has("arrayValue") else [parse]
	return Cursor.new(values_array, before)

static func _order_object(field: String, direction: int) -> Order:
	var order: Order = Order.new()
	order.obj = {"field": {"fieldPath": field}, "direction": DIRECTION.keys()[direction]}
	return order

func create_field_filter(field: String, operator: int, value: Variant) -> Dictionary:
	return {
		"fieldFilter": {
			"field": {"fieldPath": field},
			"op": OPERATOR.keys()[operator],
			"value": FirestoreDocument.dict2fields({"value": value}).fields.value
		}
	}

func create_unary_filter(field: String, operator: int) -> Dictionary:
	return {
		"unaryFilter": {
			"field": {"fieldPath": field},
			"op": OPERATOR.keys()[operator]
		}
	}

func create_composite_filter(operator: int, filters: Array[Dictionary]) -> Dictionary:
	return {
		"compositeFilter": {
			"op": OPERATOR.keys()[operator],
			"filters": filters
		}
	}

func clean() -> void:
	query = TEMPLATE_QUERY.duplicate(true)

func _to_string() -> String:
	var pretty: String = "QUERY:\n"
	for key in query.keys():
		pretty += "- %s = %s\n" % [key, query[key]]
	return pretty
