extends Control


# load game
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.


# quit game
func _on_exit_pressed() -> void:
	get_tree().quit()
