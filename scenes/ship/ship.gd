extends ScreenWrap # extends node2d aswell


@onready var ship = $"." # ship object

var velocity := Vector2(0,0) # current velocity for moving
var thrust := 5 # speed
var max_speed := 30 # speed cap
var drag := .08 # higher = less drag
var turn_speed := 2 # turning speed
var screen_wrap_offset :=  40 # how much the ship can go offscreen before being wrapped


func _physics_process(delta: float) -> void:
	handle_turning(delta)
	handle_thrust(delta)
	screen_wrap(get_viewport().get_visible_rect(),screen_wrap_offset) # wrap around screen edges
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
	get_tree().get_root().add_child(new_bullet) # add bullet to game root node
