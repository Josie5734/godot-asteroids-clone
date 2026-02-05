extends ScreenWrap

signal destroyed

@onready var asteroid = $"." # main body
@onready var asteroid_polygon = $AsteroidPolygon # shape
@onready var asteroid_collision = $AsteroidCollisionPolygon # collision shape

@export var speed = int()
@export var velocity = Vector2()

var rotate_speed = randf_range(-0.3,0.3) # how fast to rotate

var screen_wrap_margin: int # used to set how much space is given for screen wrapping
# is defined by the furthest away vertex + the minimum size/2


func _ready() -> void:
	 # generate and set points for shape and collision shape
	var polygon_points = generate_points()
	asteroid_polygon.polygon = polygon_points
	asteroid_collision.polygon = polygon_points
	

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
	var center = asteroid.global_position # center point
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


# destroy the asteroid
func destroy():
	queue_free() # remove object
	destroyed.emit()
	# right now just instantly deletes
	# will be expanded with splitting and particles and sound and stuff
