extends Node2D


@onready var asteroid_timer = %AsteroidTimer
var asteroid_count = 0
var asteroid_max = 10

@onready var ship = %Ship 


func spawn_asteroid():
	const ASTEROID  = preload("res://scenes/asteroid/asteroid.tscn")
	
	var new_asteroid = ASTEROID.instantiate()
	$AsteroidSpawnPath/SpawnPathFollow.progress_ratio = randf() # random point on the spawn path
	new_asteroid.global_position = $AsteroidSpawnPath/SpawnPathFollow.global_position # set position to random point on spawn path
	new_asteroid.speed = randi_range(20,40) # random speed
	# movement direction is set as towards the ship at the time of spawning
	new_asteroid.velocity =  Vector2(ship.global_position - new_asteroid.global_position).normalized() 
	get_tree().get_root().add_child(new_asteroid) # add to scene from root
	
	asteroid_count += 1 # iterate counter


func _on_asteroid_timer_timeout() -> void:
	if asteroid_count < asteroid_max: # if not at limit
		spawn_asteroid() # create new asteroid
	%AsteroidTimer.wait_time = 3 # reset timer
	
