extends Control

signal unpause
signal exit_button

func _on_resume_pressed() -> void:
	get_tree().paused = false
	unpause.emit() # send unpaused signal


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().paused = false # unpause for main menu to work
	exit_button.emit() # send signal for going to main menu


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"): # send unpause signal for ESC press
		# get_tree().paused = false
		get_viewport().set_input_as_handled() # set the input as handled so game.gd doesnt take it aswell
		unpause.emit() # send unpaused signal
