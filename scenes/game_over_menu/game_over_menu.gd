extends Control

signal restart
signal exit


# add the click sound effect to each buttons pressed() signal
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("ui_buttons"):
		button.pressed.connect(AudioManager.play_button_click)


func _on_restart_pressed() -> void:
	get_tree().paused = false # unpause 
	restart.emit() # send signal for restarting game


func _on_exit_pressed() -> void:
	get_tree().paused = false # unpause for main menu to work
	exit.emit() # send signal for going to main menu
