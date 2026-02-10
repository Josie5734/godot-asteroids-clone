extends Node2D

# asteroids
@onready var asteroid_timer = %AsteroidTimer
var asteroid_count = 0
var asteroid_max = 5
var asteroid_interval = 0.3


# ship
@onready var ship = %Ship 

# for managing pause menu
var pause_menu_scene = preload("res://scenes/pause_menu/pause_menu.tscn")
var pause_instance = null

# for managing game over menu
var game_over_menu_scene = preload("res://scenes/game_over_menu/game_over_menu.tscn")
var game_over_instance = null

# score
var score:int = 0 # player score
var score_add = 30 # how many points to add when scoring
var score_mult = 1 # score multiplier
var mult_calc = 20 # get a time
var score_bank = 0 # when lerping from scoreadded to score, store how many to add here
@onready var score_label = %ScoreLabel


func _ready() -> void:
	ship.connect("ship_died",ship_died) # connect to the ships death signal


func _physics_process(_delta: float) -> void:
	if score_bank > 0: # gradually increase the score value if there is score to add
		gradual_score() 


# for when the ship dies
func ship_died():
	ship.visible = false
	destroyed_particles(ship.global_position)
	game_over() # load game over sequence


# spawn a new asteroid, pass in size to say which size, option pos for spawning splits from previous asteroid
func spawn_asteroid(size, pos=Vector2.ZERO):
	var spawn_pos # position to be spawned at
	if pos != Vector2.ZERO: # if a position has been passed in
		spawn_pos = pos # use inputted position
	else: # else use spawnpath
		$AsteroidSpawnPath/SpawnPathFollow.progress_ratio = randf() # random point on the spawn path
		spawn_pos = $AsteroidSpawnPath/SpawnPathFollow.global_position # get spawn position from path
		
	var asteroid = Asteroid.create(spawn_pos,%Ship.global_position,size) # call create function
	call_deferred("add_child",asteroid)  # add asteroid as child of game scene
	asteroid.connect("destroyed",_on_asteroid_destroyed) # connect to the asteroid destroyed signal
	asteroid_count += 1 # iterate counter


# spawning asteroids from timer
func _on_asteroid_timer_timeout() -> void:
	if asteroid_count < asteroid_max: # if not at limit
		spawn_asteroid(3) # create new big asteroid
	%AsteroidTimer.wait_time = asteroid_interval # reset timer
	

# when asteroid is destroyed
func _on_asteroid_destroyed(size,pos):
	# logic for splitting asteroids
	if size == 3:
		spawn_asteroid(2,pos) # spawn 2 asteroids of size 2
		spawn_asteroid(2,pos)
	elif size == 2:
		spawn_asteroid(1,pos) # spawn 2 asteroids of size 1
		spawn_asteroid(1,pos)
	elif size == 1:
		asteroid_count -= 1 # remove 1 from asteroid count

	add_score() # add score
	
	destroyed_particles(pos) # spawn particles


# spawn destroyed particles at the given position
func destroyed_particles(pos):
	const PARTICLE = preload("res://scenes/particles/destroy.tscn") # load particle scene
	var new_particle = PARTICLE.instantiate() # create new particle object
	new_particle.global_position = pos # put at new position
	add_child(new_particle) # add into scene (automatically removes itself when done)


# input for pause menu
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"): # if pausing
		if not pause_instance:
			pause()


# pause menu functions
func pause():
	pause_instance = pause_menu_scene.instantiate() # load pause scene 
	pause_instance.global_position = get_viewport_rect().size / 2 # put in center
	$".".add_child(pause_instance) # add to tree
	pause_instance.connect("unpause",unpause) # connect to the signal for unpausing
	pause_instance.connect("exit_button",go_to_main_menu)
	
	get_tree().paused = true # pause the game


func unpause():
	if pause_instance: # if pause menu exists
		pause_instance.queue_free() # free it
		pause_instance = null # reset
		get_tree().paused = false # unpause game (should already be unpaused but just incase)


# game over menu on being hit
func game_over():
	game_over_instance = game_over_menu_scene.instantiate() # load menu
	game_over_instance.global_position = get_viewport_rect().size / 2 # center
	$".".add_child(game_over_instance) # add to tree
	game_over_instance.connect("restart",game_restart)
	game_over_instance.connect("exit",go_to_main_menu)
	
	# leaving out pausing on death so the asteroids and stuff keep just floating around
	# just uncomment VVVV to add it back in, meun has unpause code and stuff already there
	# get_tree().paused = true # pause the game


# restart the game by reloading the game scene
func game_restart():
	if game_over_instance: # if game over menu exists
		game_over_instance.queue_free() # free it
		game_over_instance = null # reset value
		get_tree().paused = false # unpause
	get_tree().reload_current_scene()
	

# exit to main menu
func go_to_main_menu():
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn") # switch to main menu scene





# manage adding to score
func add_score():
	var local_mult_calc = Time.get_unix_time_from_system() # capture time from system 
	if floor(local_mult_calc) - floor(mult_calc) < 3: # if less than 5 seconds since last asteroid destroyed
		score_mult += 0.1 # add to mult
	else:
		score_mult = 1 # reset mult
	mult_calc = local_mult_calc # set time
	score_bank = score_add * score_mult # add score to bank


# lerp function to increase score - currently unused in favour of gradual func below
# actually currently works in floats so ends up cutting numbers off and making them slightly smaller
# not sure on whether or not i want to change this yet though it adds a bit of interest to the score numbers
#func lerp_score():
#	var value = lerpf(score_bank,0,0.9) # get the value to add
#	print(value)
#	score += value # add it
#	score_bank -= value # decrease from bank
#	score_label.text = "Score: " + str(score) # update score label

# gradually increase the score by 1 until the banked score is depleted
# to create a smooth increase of the score counter
func gradual_score():
	score += 1
	score_bank -= 1
	score_label.text = "Score: " + str(score) # update score label
