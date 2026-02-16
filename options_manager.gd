extends Node

# global script for loading and managing option data in the options menu
var options_path = "user://settings.cfg" # path to options file
var options_file = ConfigFile.new() # options file object

# volumes as a 0-100 range from the slider, converted to db range later on 
var audio = {
	"Master": 100, 
	"Music": 50,
	"Game-FX": 50,
	"UI-FX": 50
}


# on startup
func _ready() -> void: 
	load_settings() # load settings 
	set_bus_sliders() # set audio bus volumes


# load the settings from file
func load_settings():
	if options_file.load(options_path) != OK: # error check
		default_settings() # create a default settings file
	
	for section in options_file.get_sections(): # for each section
		for key in options_file.get_section_keys(section): # for each key in section
			if section == "Audio": # for audio section
				audio[key] = options_file.get_value(section,key) # set the audio slider value to the saved value


# save settings to file
func save_settings():
	for key in audio: # for each item in audio dict
		options_file.set_value("Audio",key,audio[key]) # set values
	
	options_file.save(options_path) # save new file


# create default settings file
func default_settings():
	for bus in audio: # for each audio bus
		options_file.set_value("Audio",str("",bus),audio[bus]) # write default value to file


# set the values of each of the audio buses (recieves value from signal but ignores it)
func set_bus_sliders():
	for bus in audio: # for each bus
		var bus_id = AudioServer.get_bus_index(bus) # get bus object
		var value = audio[bus] # get the value of the current bus
		# convert the inputted 0-100 slider value to a value on the audio bus
		var valf: float = value / 100 # convert to a float 0.00 - 1.00
		valf = valf * valf # square it to make logarithmic like db
		var db_val = linear_to_db(valf) if valf != 0.0 else -80 # convert to db, set to minimum if 0 to avoid -inf error
		AudioServer.set_bus_volume_db(bus_id,db_val) # set the bus value
