extends Timer

class_name WaitTimer

func wait_for_seconds(seconds: float) -> void:	
	wait_time = seconds
	autostart = true
	get_tree().root.add_child(self)


func _on_WaitTimer_timeout():
	queue_free()
