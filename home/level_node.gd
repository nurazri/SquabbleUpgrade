extends Control

signal start_level

@export var level_base_uncleared: Texture2D
@export var level_base_current: Texture2D
@export var level_base_cleared: Texture2D

@onready var stage: Label = $Stage
@onready var base: TextureRect = $Level_Base
@onready var highlight: TextureRect = $Level_Highlight
@onready var glow: TextureRect = $Level_Glow
@onready var rating: Control = $Clear_Rating
@onready var star_fills: Array[Node] = [
	rating.get_node("1_Star/Fill"),
	rating.get_node("2_Star/Fill"),
	rating.get_node("3_Star/Fill")
]

var this_level: int = 0

func init(level, completion, star):
	var grandparent = get_parent().get_parent()
	if completion == 0:
		base.texture = level_base_uncleared
	if completion == 1: 
		base.texture = level_base_current
	if completion == 2: 
		base.texture = level_base_cleared
		
	stage.text = str(level)
	highlight.show() if completion == 1 else highlight.hide()
	glow.show() if completion == 1 else glow.hide()
	rating.show() if completion == 2 else rating.hide()
	
	for i in star:
		print("i is: ", i)
		if i < star:
			star_fills[i].show()
		else:
			star_fills[i].hide()
		#rating.get_node(str(i + 1) + "_Star/Fill").show()
	this_level = level


func _on_Play_pressed():
	emit_signal("start_level", this_level, true, false)
