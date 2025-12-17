extends Control

signal game_started(mode: int, level: int)
signal custom_game_started(
	mode: int,
	opponent: int,
	word_mix: String,
	dictionary: String,
	reaction: int,
	point_condition: int
)
signal page_changed(page_type: int)

# --------------------------------------------------
# NODES
# --------------------------------------------------
@onready var header_UI: Control = get_node_or_null("Header_UI/New_Header")
@onready var footer_UI: Control = get_node_or_null("Header_UI/New_Footer")
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Dummy nodes for Loading.load_next(Node, Callable, Node)
@onready var dummy_node1: Node = Node.new()
@onready var dummy_node3: Node = Node.new()

# --------------------------------------------------
# VARIABLES
# --------------------------------------------------
var max_scroll_distance: int = 0
var custom_scroll_dist: Array[int] = [0, 1135, 1135, 1190, 1260, 1260]
var current_page: int = Globals.PageType.HOME
var last_check_in: Dictionary = {}
var limit_scroll: int = 0

# Prevent recursion in visibility changes
var _updating_visibility: bool = false

# --------------------------------------------------
# READY / PROCESS
# --------------------------------------------------
func _ready() -> void:
	if Engine.has_singleton("GameLoader"):
		var loader = Engine.get_singleton("GameLoader") as GameLoaderManager
		loader.game_saved.connect(_on_GameLoader_game_saved)
		loader.achievement_saved.connect(_on_GameLoader_achievement_saved)
		loader.currency_updated.connect(on_currency_changed)
	start()


func _process(_delta: float) -> void:
	if scroll_container != null and scroll_container.get_v_scroll() <= max_scroll_distance:
		scroll_container.set_v_scroll(max_scroll_distance + 1)

# --------------------------------------------------
# STARTUP
# --------------------------------------------------
func start() -> void:
	var avatar: int = GameLoader.get_save_data("avatar") if GameLoader.has_method("get_save_data") else 0
	set_avatar(avatar)
	on_currency_changed()
	on_stage_updated()

# --------------------------------------------------
# AVATAR
# --------------------------------------------------
func set_avatar(which: int) -> void:
	if header_UI == null:
		return
	header_UI.get_node("Header/Avatar/Character").texture = Globals.AvatarTextures[which]
	header_UI.get_node("Header/Avatar/Label").text = Globals.AvatarNames[which]

# --------------------------------------------------
# PAGE CHANGE
# --------------------------------------------------
func _on_redirect_page(this_page: int, extra_params: String) -> void:
	change_page(this_page, extra_params)

func change_page(page: int, extra_parameters: String = "") -> void:
	if footer_UI == null:
		return

	var prev_btn: String = String(Globals.PageButtons[current_page])
	var new_btn: String = String(Globals.PageButtons[page])

	var tween := create_tween()

	if prev_btn != "":
		var previous_page: Control = footer_UI.get_node("HBoxContainer/" + prev_btn)
		if prev_btn == "Adventure" and header_UI != null:
			header_UI.get_node("Location").hide()
		tween.tween_property(previous_page, "custom_minimum_size", Vector2(166, 136), 0.15)

	if new_btn != "":
		var new_page: Control = footer_UI.get_node("HBoxContainer/" + new_btn)
		if new_btn == "Adventure" and header_UI != null:
			header_UI.get_node("Location").show()
		tween.tween_property(new_page, "custom_minimum_size", Vector2(260, 190), 0.15)

	if Globals.PageName[current_page] != "":
		get_node(Globals.PageName[current_page]).hide()

	if Globals.PageName[page] != "":
		var page_node: Node = get_node(Globals.PageName[page])
		if page_node.has_method("set_extra_params"):
			page_node.set_extra_params(extra_parameters)
		page_node.show()

	current_page = page

# --------------------------------------------------
# PLAY LEVEL
# --------------------------------------------------
func play_level(this_level: int = 0, play_sfx: bool = true, play_animation: bool = false) -> void:
	if GameLoader.player_data["current_level"] < this_level:
		return

	if play_sfx:
		Audio.play_sfx(Audio.Sfx.BUTTON_TAP)

	hide()

	var game_mode: int = Globals.GameMode.VS_AI
	if this_level <= 7:
		game_mode = Globals.GameMode.TUTORIAL

	Loading.load_next(dummy_node1, Callable(), dummy_node3)
	await Loading.screen_loaded

	game_started.emit(game_mode, this_level)

# --------------------------------------------------
# PLAY CUSTOM GAME
# --------------------------------------------------
func play_custom_game(
	opponent: int,
	word_mix: String,
	dictionary: String,
	reaction: int,
	point_condition: int
) -> void:
	Audio.play_sfx(Audio.Sfx.BUTTON_TAP)
	change_page(Globals.PageType.HOME)

	modulate = Color.TRANSPARENT
	if header_UI != null: header_UI.modulate = Color.TRANSPARENT
	if footer_UI != null: footer_UI.modulate = Color.TRANSPARENT
	$Header_UI/Blocker.show()

	await Loading.screen_loaded
	hide()

	modulate = Color.WHITE
	if header_UI != null: header_UI.modulate = Color.WHITE
	if footer_UI != null: footer_UI.modulate = Color.WHITE
	$Header_UI/Blocker.hide()

	custom_game_started.emit(
		Globals.GameMode.VS_AI,
		opponent,
		word_mix,
		dictionary,
		reaction,
		point_condition
	)

# --------------------------------------------------
# GAMELOADER CALLBACKS
# --------------------------------------------------
func _on_GameLoader_game_saved() -> void:
	var avatar: int = GameLoader.get_save_data("avatar") if GameLoader.has_method("get_save_data") else 0
	set_avatar(avatar)
	on_currency_changed()
	on_stage_updated()
	if has_node("$Profile_Page"): $Profile_Page.on_Load()
	if has_node("$Inventory_Page"): $Inventory_Page.on_Load()

func _on_GameLoader_achievement_saved() -> void:
	if has_node("$Achievement_Page"): $Achievement_Page.reload()
	if has_node("$Profile_Page"): $Profile_Page.on_Load()
	if has_node("$Inventory_Page"): $Inventory_Page.on_Load()

# --------------------------------------------------
# CURRENCY
# --------------------------------------------------
func on_currency_changed() -> void:
	_set_player_coins(GameLoader.load_currency("coins"))
	_set_player_diamonds(GameLoader.load_currency("diamonds"))

func _set_player_coins(value: int) -> void:
	if header_UI != null:
		header_UI.get_node("Header/Coin/UserCoin").text = str(value)

func _set_player_diamonds(value: int) -> void:
	if header_UI != null:
		header_UI.get_node("Header/Diamond/UserDiamond").text = str(value)

# --------------------------------------------------
# STAGE UPDATE
# --------------------------------------------------
func on_stage_updated() -> void:
	var this_level: int = 1

	for i in range(1, 10):
		var level_list_path := "ScrollContainer/VBoxContainer/Background%d/Level_List" % i
		if not has_node(level_list_path):
			continue

		for level_button in get_node(level_list_path).get_children():
			var progress: Dictionary = {}
			if this_level <= Globals.currentLevelLimit and GameLoader.player_data["level_progression"].has(str(this_level)):
				progress = GameLoader.player_data["level_progression"][str(this_level)] as Dictionary

			if this_level > Globals.currentLevelLimit:
				level_button.init(this_level, 0, 0)
			else:
				level_button.init(this_level, progress.get("completion", 0), progress.get("rating", 0))
				if not level_button.is_connected("start_level", Callable(self, "play_level")):
					level_button.connect("start_level", Callable(self, "play_level"))

			this_level += 1

	var current_stage: int = get_current_stage()

	for cloud in $ScrollContainer/Cloud_List.get_children():
		cloud.hide()

	get_node("ScrollContainer/Cloud_List/Cloud_Overlay" + str(current_stage)).show()
	max_scroll_distance = 13323 - (custom_scroll_dist[current_stage] * current_stage)

# --------------------------------------------------
# VISIBILITY
# --------------------------------------------------
func _on_Home_visibility_changed() -> void:
	if _updating_visibility:
		return
	_updating_visibility = true

	if not is_inside_tree():
		_updating_visibility = false
		return

	await get_tree().process_frame

	if header_UI == null or footer_UI == null:
		_updating_visibility = false
		return

	if visible and animation_player != null:
		animation_player.play("Homescreen_Entrance")

	header_UI.visible = visible
	footer_UI.visible = visible

	_updating_visibility = false

# --------------------------------------------------
# STAGE HELPER
# --------------------------------------------------
func get_current_stage() -> int:
	var get_stage: int = GameLoader.player_data["current_level"] - 7
	var set_stage: int = 0

	for i in range(0, 5):
		if get_stage <= (i * 10):
			set_stage = i
			break
		set_stage = i

	return set_stage
