extends Node

var sfxplayer: AudioStreamPlayer # sound effects player for ui click fx
var bgplayer: AudioStreamPlayer # background music player


func _ready() -> void:
	sfxplayer = AudioStreamPlayer.new() # create audiostreamplayer node
	add_child(sfxplayer) # add to whatever current scene is
	sfxplayer.stream = preload("res://sounds/click.wav") # add in the click sound effect
	sfxplayer.bus = "UI-FX"
	
	background_music_ready() # prepare background music 
	bgplayer.play() # play background music


func play_button_click(): # play the button click sound
	sfxplayer.play()


# background music
func background_music_ready():
	bgplayer = AudioStreamPlayer.new()
	add_child(bgplayer)
	bgplayer.stream = preload("res://sounds/asteroids_bg.ogg")
	bgplayer.bus = "Music"
	bgplayer.autoplay = true
	
