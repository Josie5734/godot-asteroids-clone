extends Control

signal restart
signal exit

func _on_restart_pressed() -> void:
	get_tree().paused = false # unpause 
	restart.emit() # send signal for restarting game


func _on_exit_pressed() -> void:
	get_tree().paused = false # unpause for main menu to work
	exit.emit() # send signal for going to main menu
