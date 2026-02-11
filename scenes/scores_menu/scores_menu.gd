extends Control

var score_box_str = "Score: " # the start of the score string for every label


# apply scores from save file on loading menu
func _ready() -> void: # apply values from save when menu loaded
	apply_values_to_labels()


# exit back to main menu
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


# overwrite the current score file with an empty one
func _on_delete_scores_pressed() -> void:
	SaveManager.clear_scores() 
	apply_values_to_labels() # re-apply values


# take the saved data and put it into the labels
func apply_values_to_labels():
	for i in range(10): # for each value
		# get the label node and swap the text for the value
		var score_node = get_node(str("ScoresVbox/ScoreListContainer/LeftHalf/ScoreColumn/Score",i+1))
		score_node.text = str(score_box_str, "%09d" % int(SaveManager.score_list[i]))
		
		var date_node = get_node(str("ScoresVbox/ScoreListContainer/RightHalf/DateColumn/Date",i+1))
		date_node.text = str(SaveManager.date_list[i])
