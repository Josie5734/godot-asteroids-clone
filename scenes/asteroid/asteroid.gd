extends ScreenWrap
class_name Asteroid

signal destroyed

@onready var asteroid = $"." # main body
@onready var asteroid_polygon = $AsteroidPolygon # shape
@onready var asteroid_collision = $AsteroidCollisionPolygon # collision shape

@export var speed = int()
@export var velocity = Vector2()

var size = 3 # the size of the asteroid
# 3 - big
# 2 - medium
# 1 - small

const SIZES = { # dict of sizes for scaling asteroids
	3: Vector2(1,1),
	2: Vector2(0.6,0.6),
	1: Vector2(0.3,0.3)
}

var rotate_speed = randf_range(-0.3,0.3) # how fast to rotate

var screen_wrap_margin: int # used to set how much space is given for screen wrapping
# is defined by the furthest away vertex + the minimum size/2


func _ready() -> void:
	 # generate and set points for shape and collision shape
	var polygon_points = generate_points()
	asteroid_polygon.polygon = polygon_points
	asteroid_collision.set_deferred("polygon",polygon_points) 
	

func _physics_process(delta: float) -> void:
	asteroid.global_position += velocity # move
	asteroid.global_rotation += rotate_speed * delta # rotate
	screen_wrap(get_viewport_rect(),screen_wrap_margin) # wrap around screen


# generate the asteroid shape
#TODO: 
# adjust spawning position to be slightly outside of the screen so they have some time to slide in
# adjust angle so that they point towards where the ship is at the time of spawning
#	rather than just in the same direction
func generate_points():
	var polygon_points = PackedVector2Array()
	var point_count = 8 # number of points
	var min_radius = 40
	var angle = 360 / point_count # angle of each point in degrees
	var start_angle = 0
	
	var furthest_point: int
	
	for p in point_count: # for each point
		var r = min_radius + (randi() % min_radius) # generate random distance
		var vertex = Vector2.from_angle(deg_to_rad(start_angle)) * r # coords for the vertex point
		polygon_points.append(vertex) # add point to polygon array
		start_angle += angle # iterate to next angle
		if r > furthest_point: screen_wrap_margin = r + (min_radius/2) # set furthest point from center as screenwrap margin

	return polygon_points # send back the points array 


# creates a new asteroid object. asteroid_pos is either a point on the spawnpath or a given vector coordinate
static func create(asteroid_pos: Vector2, ship_pos: Vector2, size) -> Node2D:
	const ASTEROID  = preload("res://scenes/asteroid/asteroid.tscn")
	var new_asteroid = ASTEROID.instantiate()
	new_asteroid.global_position = asteroid_pos  # set position to random point on spawn path or given coordinate


	if size == 3: # if a big one
		new_asteroid.speed = randi_range(20,40) # random speed
		
		# get direction to the ship
		new_asteroid.velocity =  Vector2(ship_pos - new_asteroid.global_position).normalized()
		var random_angle = randf_range(-PI/5,PI/5) # random range for offset
		new_asteroid.velocity = new_asteroid.velocity.rotated(random_angle) # add the random angle as an offset to the direction
		
	else: # else smaller ones
		new_asteroid.speed = randi_range((20*(size/5)),(40*(size/5))) # random speed (higher than normal)
		new_asteroid.velocity =  Vector2(randf(),randf()) # random direction 

	new_asteroid.scale = SIZES[size] # set the size of the asteroid
	new_asteroid.size = size # set the size variable in the script
	
	return new_asteroid # send it back to the game script


# destroy the asteroid
func destroy():
	queue_free() # remove object
	destroyed.emit(size,asteroid.global_position) # emit signal with the size and pos of the asteroid
	# right now just instantly deletes
	# will be expanded with splitting and particles and sound and stuff
