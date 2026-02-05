extends Node2D


@onready var asteroid_timer = %AsteroidTimer
var asteroid_count = 0
var asteroid_max = 10

@onready var ship = %Ship 

# for managing pause menu
var pause_menu_scene = preload("res://scenes/pause_menu/pause_menu.tscn")
var pause_instance = null


# spawn a new asteroid
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
	
	new_asteroid.connect("destroyed",_on_asteroid_destroyed) # connect to the asteroid destroyed signal


func _on_asteroid_timer_timeout() -> void:
	if asteroid_count < asteroid_max: # if not at limit
		spawn_asteroid() # create new asteroid
	%AsteroidTimer.wait_time = 3 # reset timer
	

# when asteroid is destroyed
func _on_asteroid_destroyed():
	asteroid_count -= 1 # remove 1 from asteroid count


# input for pause menu
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"): # if pausing
		if pause_instance:
			unpause()
		else:
			pause()



func pause():
	pause_instance = pause_menu_scene.instantiate() # load pause scene 
	pause_instance.global_position = get_viewport_rect().size / 2 # put in center
	$".".add_child(pause_instance) # add to tree
	pause_instance.connect("unpause",unpause) # connect to the signal for unpausing
	
	get_tree().paused = true # pause the game


func unpause():
	if pause_instance: # if pause menu exists
		pause_instance.queue_free() # free it
		pause_instance = null # reset
		get_tree().paused = false # unpause game (should already be unpaused but just incase)
