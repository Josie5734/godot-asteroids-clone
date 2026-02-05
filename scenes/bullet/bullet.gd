extends Area2D

var travel_distance = 0

func _physics_process(delta: float) -> void:
	const SPEED = 1000 # travel speed
	const RANGE = 1500 # distance until despawn
	
	var direction = Vector2.LEFT.rotated(rotation) # set direction
	position += direction * SPEED * delta # move
	
	travel_distance += SPEED * delta # update distance
	
	if travel_distance > RANGE: # kill after range
		queue_free()


# when bullet enters an Area2D
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("asteroids"): # if area has method destroy
		queue_free() # delete bullet
		area.destroy() # call destroy method
