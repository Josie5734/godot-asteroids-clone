extends Node2D
class_name ScreenWrap


# wrap an object around the screen, takes a Rect2 for screen dimensions
# and margin for how much to let object fly off screen first
func screen_wrap(bounds: Rect2, margin: int):
	# horizontal
	if global_position.x < bounds.position.x - margin: # off left
		global_position.x = bounds.end.x + margin # send to right
	elif global_position.x > bounds.end.x + margin: # off right
		global_position.x = bounds.position.x - margin # send to left
		
	# vertical
	if global_position.y < bounds.position.y - margin: # off bottom
		global_position.y = bounds.end.y + margin # send to top
	elif global_position.y > bounds.end.y + margin: # off top
		global_position.y = bounds.position.y - margin # send to bottom
