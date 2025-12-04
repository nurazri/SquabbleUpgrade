extends Control


func reset() -> void:
	$TilesCounterLabel.text = "TILES LEFT:" + str(WordList.get_spawned_letters_quantity_left())
	show()


func _on_Pool_letter_spawned(_letter: Letter):
	$TilesCounterLabel.text = "TILES LEFT:" + str(WordList.get_spawned_letters_quantity_left())
	$AnimTilesCounter.play("count")
