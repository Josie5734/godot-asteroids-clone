extends Control


# add the click sound effect to each buttons pressed() signal
func _ready() -> void:
	for button in get_tree().get_nodes_in_group("ui_buttons"):
		button.pressed.connect(AudioManager.play_button_click)


# exit back to main menu
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
