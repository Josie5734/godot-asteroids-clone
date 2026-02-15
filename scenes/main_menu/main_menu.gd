extends Control


# add the click sound effect to each buttons pressed() signal
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("ui_buttons"):
		button.pressed.connect(AudioManager.play_button_click)


# load game
func _on_play_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_options_pressed() -> void:
	pass



func _on_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scores_menu/scores_menu.tscn")


# quit game
func _on_exit_pressed() -> void:
	get_tree().quit()
