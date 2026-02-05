extends Node2D

@onready var ship = $ShipBody # ship body object

var velocity := Vector2(0,0) # current velocity for moving
var thrust := 5 # speed
var max_speed := 30 # speed cap
var drag := .08 # higher = less drag
var turn_speed := 2 # turning speed
var screen_wrap_offset :=  40 # how much the ship can go offscreen before being wrapped


func _physics_process(delta: float) -> void:
	handle_turning(delta)
	handle_thrust(delta)
	screen_wrap()
	if Input.is_action_just_pressed("shoot"):
		shoot()


# input for rotating 
func handle_turning(delta):
	var turn := (
		Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	)
	ship.rotation += turn * turn_speed * delta


# handle input for accelerating and drag when not accelerating
func handle_thrust(delta):
	# acceleration
	if Input.is_action_pressed("accelerate"): # apply speed caps
		if abs(velocity.x) < max_speed: velocity.x -= cos(ship.global_rotation) * thrust * delta 
		if abs(velocity.y) < max_speed: velocity.y -= sin(ship.global_rotation) * thrust * delta 
	else: # drag if not moving
		velocity -= velocity.lerp(Vector2(0,0),drag) * delta
	ship.global_position += velocity


# shoot bullet
func shoot():
	const BULLET = preload("res://scenes/bullet/bullet.tscn")
	
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = ship.global_position
	new_bullet.global_rotation = ship.global_rotation
	$".".add_child(new_bullet)


# wrap the ship around the edges of the screen
func screen_wrap():
	# horizontal
	if ship.global_position.x > get_viewport().size.x + screen_wrap_offset:
		ship.global_position.x = -screen_wrap_offset
	elif ship.global_position.x < -screen_wrap_offset:
		ship.global_position.x = get_viewport().size.x + screen_wrap_offset
	
	# vertical
	if ship.global_position.y > get_viewport().size.y + screen_wrap_offset:
		ship.global_position.y = -screen_wrap_offset
	elif ship.global_position.y < -screen_wrap_offset:
		ship.global_position.y = get_viewport().size.y + screen_wrap_offset
