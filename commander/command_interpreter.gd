class_name CommandInterpreter
extends Node2D

@export var show_current_command: bool = false

signal command_succeeded
signal command_failed
signal commands_finished
signal commands_interrupted

var _command: Array = []

var timer: Timer


func _ready():
	timer = Timer.new()
	timer.wait_time = 0.01
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)
	# warning-ignore:return_value_discarded
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))


func init() -> void:
	timer.stop()
	_command.clear()


func command(command: Array) -> void:
	_command.append(command)
	var interval: float = 0.0
	if command.size() != 6:
		interval = command[command.size() - 1]
	#var interval: float = 0.0
	if timer:
		if interval > 0:
			if timer.is_stopped():
				timer.wait_time = interval
				timer.start()
		else:
			_on_Timer_timeout()


func interpret(_current_command: Array) -> bool:
	return true


func _on_Timer_timeout() -> void:
	var current_command: Array = []
	
	if not _command.is_empty():
		current_command = _command[0]
		
		if show_current_command:
			print("[CommandInterpreter] current command: " + str(current_command))
		
		if interpret(current_command):
			emit_signal("command_succeeded", current_command)
		else:
			emit_signal("command_failed", current_command)
			
		_command.remove(0)
		
		if not _command.is_empty():
			current_command = _command[0]
			var interval: float = current_command[current_command.size() - 1]
			if interval >= 0:
				timer.wait_time = interval
				timer.start()
			else:
#				print("[CommandInterpreter] commands interrupted!")
				emit_signal("commands_interrupted")
		else:
#			print("[CommandInterpreter] commands finished!")
			emit_signal("commands_finished")


func _exit_tree():
	timer.queue_free()
	queue_free()
