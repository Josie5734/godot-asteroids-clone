extends AudioStreamPlayer2D

func _ready() -> void:
	play() # play when loaded
	finished.connect(queue_free) # destroy itself when done
