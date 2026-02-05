extends Node2D

# asteroid generation
# create a number of points 
# make a minimum distance from the center point
# all points = minimum + random()

@onready var asteroid_polygon = $AsteroidPolygon # shape
@onready var asteroid_collision = $AsteroidArea/AsteroidCollisionPolygon # collision shape

var speed = 20
var velocity = Vector2()

func _ready() -> void:
	var polygon_points = generate_points()
	asteroid_polygon.polygon = polygon_points # set points for shape and collision shape
	asteroid_collision.polygon = polygon_points
	
	velocity = Vector2(cos(asteroid_polygon.global_rotation * speed),sin(asteroid_polygon.global_rotation * speed))


func _physics_process(delta: float) -> void:
	$".".global_position += velocity
	# movement
	

# generate the asteroid shape
func generate_points():
	var polygon_points = PackedVector2Array()
	var point_count = 8 # number of points
	var center = asteroid_polygon.global_position # center point
	var min_radius = 40
	var angle = 360 / point_count # angle of each point in degrees
	var start_angle = 0
	
	for p in point_count: # for each point
		var r = min_radius + (randi() % min_radius) # generate random distance
		var vertex = center + Vector2.from_angle(deg_to_rad(start_angle)) * r # get the point coords vector
		start_angle += angle # iterate to next angle
		polygon_points.append(vertex) # add point to polygon array

	return polygon_points # send back the points array 
