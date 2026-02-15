extends Node

var player: AudioStreamPlayer 


func _ready() -> void:
	player = AudioStreamPlayer.new() # create audiostreamplayer node
	add_child(player) # add to whatever current scene is
	player.stream = preload("res://sounds/click.wav") # add in the click sound effect


func play_button_click(): # play the button click sound
	player.play()
