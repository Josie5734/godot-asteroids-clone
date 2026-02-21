extends Node2D

# asteroids
@onready var asteroid_timer = %AsteroidTimer
var asteroid_count = 0
var asteroid_max = 5
var asteroid_interval = 0.3

# ship
@onready var ship = %Ship 

# lives
var lives = 3 # number of lives
@onready var lives_ui = { # references to ui nodes for each life
	"0" = %LifeIcon1, # used to blink and remove them on losing a life
	"1" = %LifeIcon2,
	"2" = %LifeIcon3
}

# SFX
const EXPLOSION = preload("res://sounds/explosion_sfx.tscn")

# for managing pause menu
var pause_menu_scene = preload("res://scenes/pause_menu/pause_menu.tscn")
var pause_instance = null

# manaing options menu
var options_menu_scene = preload("res://scenes/options_menu/options_menu.tscn")
var options_instance = null

# for managing game over menu
var game_over_menu_scene = preload("res://scenes/game_over_menu/game_over_menu.tscn")
var game_over_instance = null

# score
var score:int = 0 # player score
var score_add = 30 # how many points to add when scoring
var score_mult = 1 # score multiplier
var mult_calc = 20 # get a time
var score_bank:int = 0 # when lerping from scoreadded to score, store how many to add here
@onready var score_label = %ScoreLabel


func _ready() -> void:
	ship.connect("ship_died",ship_died) # connect to the ships death signal


func _physics_process(_delta: float) -> void:
	if score_bank > 0: # gradually increase the score value if there is score to add
		gradual_score() 


# fade an object by reducing its modulate.a property to 0
func fade(object):
	var tween = create_tween() # tween obj
	tween.tween_property(object,"modulate:a",0.0,1.0) # tween down to 0


# for when the ship dies
func ship_died():
	lives -= 1 # decrease lives
	fade(lives_ui[str(lives)]) # fade the matching ui life icon
	
	ship.visible = false # make invisible
	ship.get_node("ShipCollision").set_deferred("disabled", true) # disable collision
	ship.set_physics_process(false) # disable physics process to disable inputs
	destroyed_particles(ship.global_position) # spawn particles
	
	if lives <= 0: # if out of lives
		game_over() # load game over sequence
	else: # otherwise do respawn sequence
		ship_respawn()


# ship respawning
func ship_respawn():
	await get_tree().create_timer(2).timeout # wait 2 seconds
	ship.velocity = Vector2(0,0) # reset velocity
	ship.global_position = get_viewport_rect().get_center() # put in center
	ship.visible = true # make visible again
	ship.set_physics_process(true) # re-enable physic process for inputs
	
	blink(ship,20,0.1,"visible") # blink 
	await get_tree().create_timer(2).timeout # 2 second timer for invincibility
	ship.visible = true # set ship visible (might be already but just to be sure
	ship.get_node("ShipCollision").set_deferred("disabled", false) # re-enable collision



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


# blink an object X times at Y frequency, type is either visible or modulate
func blink(object, times, freq, type):
	for i in range(times): # for x times 
		await get_tree().create_timer(freq).timeout # wait Y seconds
		if type == "visible": # flip visible property
			object.visible = not object.visible # flip visibility
		else: # else flip modulate.a property
			object.modulate.a = 0.0 if object.modulate.a != 255.0 else 255.0

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
	var sfx = EXPLOSION.instantiate() # create new sfx node
	sfx.global_position = pos # put at asteroid position
	add_child(sfx) # add to tree
	# it autoplays itself and then destroys itself


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
	add_child(pause_instance) # add to tree
	pause_instance.connect("unpause",unpause) # connect to the signal for unpausing
	pause_instance.connect("options",options) # connect to signal for options menu
	pause_instance.connect("exit_button",go_to_main_menu)
	
	get_tree().paused = true # pause the game


func unpause():
	if pause_instance: # if pause menu exists
		pause_instance.queue_free() # free it
		pause_instance = null # reset
		get_tree().paused = false # unpause game (should already be unpaused but just incase)


# manage options menu
func options():
	if options_instance: # if options menu exists
		options_instance.queue_free() # free it
		options_instance = null # reset
		pause_instance.visible = true # make pause menu visible again
	else: # else no options menu
		pause_instance.visible = false # make pause menu invisible
		options_instance = options_menu_scene.instantiate() # create new options menu
		options_instance.global_position = get_viewport_rect().size / 2 # put in center
		options_instance.connect("game_exit",options) # close signal, should call this function
			# and get the above section since its open now
		add_child(options_instance) # add to scene



# game over menu on being hit
func game_over():
	game_over_instance = game_over_menu_scene.instantiate() # load menu
	game_over_instance.global_position = get_viewport_rect().size / 2 # center
	add_child(game_over_instance) # add to tree
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
	SaveManager.assess_save(score+score_bank) # send current score to be assessed/saved
	get_tree().reload_current_scene()
	

# exit to main menu
func go_to_main_menu():
	SaveManager.assess_save(score+score_bank) # send current score to be assessed/saved
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


# gradually increase the score by 1 until the banked score is depleted
# to create a smooth increase of the score counter
func gradual_score():
	score += 1
	score_bank -= 1
	score_label.text = "Score: " + str(score) # update score label

# lerp function to increase score - currently unused in favour of gradual func above
# actually currently works in floats so ends up cutting numbers off and making them slightly smaller
# not sure on whether or not i want to change this yet though it adds a bit of interest to the score numbers
#func lerp_score():
#	var value = lerpf(score_bank,0,0.9) # get the value to add
#	print(value)
#	score += value # add it
#	score_bank -= value # decrease from bank
#	score_label.text = "Score: " + str(score) # update score label
