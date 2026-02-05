extends Node2D

# needs to ranomly spawn asteroids

@onready var asteroid_timer = %AsteroidTimer
var asteroid_count = 0
var asteroid_max = 10


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print(event.position)


func spawn_asteroid():
	const ASTEROID  = preload("res://scenes/asteroid/asteroid.tscn")
	
	var new_asteroid = ASTEROID.instantiate()
	new_asteroid.global_position = Vector2(randi_range(0,1280),randi_range(0,720)) # random position
	new_asteroid.global_rotation = get_angle_to($Ship.global_position) # point towards ship
	$".".add_child(new_asteroid) # add to scene
	
	print("spawning at ", new_asteroid.global_position)
	print(get_viewport_rect())
	
	asteroid_count += 1 # iterate counter


func _on_asteroid_timer_timeout() -> void:
	if asteroid_count < asteroid_max:
		spawn_asteroid()
	%AsteroidTimer.wait_time = 3 # reset timer
	
