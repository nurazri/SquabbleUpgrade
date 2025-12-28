class_name Page
extends Control

signal on_return
signal on_reset
signal on_update
signal redirect_page

var extra_params: String = ""


func send_page_update(coin, diamond) -> void:
	emit_signal("on_update", coin, diamond)


func return_page(pass_in_func: Callable = Callable(), finalize: bool = true) -> void:
	if not pass_in_func.is_null():
		pass_in_func.call()

	if not finalize:
		return

	hide()
	emit_signal("on_return")
