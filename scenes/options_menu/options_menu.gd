extends Control

signal game_exit # for exiting menu opened from game scene

# audio slider nodes
@onready var sliders := {
	"Master": %AudioMasterSlider,
	"Music": %AudioMusicSlider,
	"Game-FX": %AudioGameFXSlider,
	"UI-FX": %AudioUIFXSlider
}


# add the click sound effect to each buttons pressed() signal
func _ready() -> void:
	if get_parent().name == "Game": # if open within game scene (from pause menu)
		$Background.visible = false # set background to invisible to use existing game one
	
	for button in get_tree().get_nodes_in_group("ui_buttons"): # get all the buttons in scene
		if not button.pressed.is_connected(AudioManager.play_button_click): # check not already connected
			button.pressed.connect(AudioManager.play_button_click) # connect to button click sfx
	
	OptionsManager.load_settings() # load settings
	
	set_sliders_value() # set value of sliders
	
	# connect slider change signal
	for slider in get_tree().get_nodes_in_group("audio_sliders"): 
		slider.value_changed.connect(get_sliders_value) # when any slider changed, change bus sliders


# exit back to main menu
func _on_exit_pressed() -> void:
	OptionsManager.save_settings() # save settings on exit
	if get_parent().name == "Game": # if open within game scene (from pause menu)
		game_exit.emit() # send game scene signal to close
	else: # else just load back to main menu
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")



# set the value of the sliders
func set_sliders_value():
	for slider in sliders: # for each slider in dict
		sliders[slider].value = OptionsManager.audio[slider] # set the sliders value to the one in the dict


# get the value of the sliders
func get_sliders_value(_val:float):
	for slider in sliders: # for each slider in dict
		OptionsManager.audio[slider] = sliders[slider].value # read value and set into audio dict
	OptionsManager.set_bus_sliders()
