extends Control

signal unpause

func _on_resume_pressed() -> void:
	get_tree().paused = false
	unpause.emit() # send unpaused signal


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	print("exit")
