extends Node

# singleton for global access of the save file contents
# as well as functions for reading and saving

var save_path = "user://saves.cfg" # save file path
var save_file = ConfigFile.new() # the save file
# uses a ConfigFile since its just 2 sets of 10 lines

var score_list = [] # list of scores
var date_list = [] # list of dates


# read the save file when ready at startup
func _ready() -> void:
	read_save()


# script for all score related functions
func read_save():
	score_list.clear() # clear the current values
	date_list.clear()
	
	var err = save_file.load(save_path) 
	if err != OK: # error check
		clear_scores() # if file doesnt exist, create a new empty one
		return
	
	for section in save_file.get_sections(): # for each section
		for key in save_file.get_section_keys(section): # go through each item
			var value = save_file.get_value(section,key) # get the value
			if section == "Scores": # append item to corresponding list
				value = "%09d" % int(value) # pad out the 0s first (also converts to string)
				score_list.append(value)
			elif section == "Dates":
				date_list.append(value)


# take a given score and assess if it is a new high score
func assess_save(score):
	for i in score_list.size(): # for each score in the list (using index instead of item)
		if score > int(score_list[i]): # if score is bigger
			score_list.insert(i,score) # insert at that index
			date_list.insert(i,Time.get_datetime_string_from_system(false,true)) # put the date in
			score_list.remove_at(score_list.size()-1) # remove last item
			date_list.remove_at(date_list.size()-1)
			save_score() # save the new result
			return # exit


# save the current score settings 
func save_score():
	for i in range(10): # put current list of scores/dates into file
		save_file.set_value("Scores",str("score",i),"%09d" % int(score_list[i]))
		save_file.set_value("Dates",str("date",i),date_list[i])
	save_file.save(save_path) # save


# clears the scores savefile and overwrites it with an empty one
func clear_scores():
	for i in range(10): # create empty scores and dates
		save_file.set_value("Scores",str("score",i),"%09d" % 000000000)
		save_file.set_value("Dates",str("date",i),"xxxx-xx-xx xx:xx:xx")
		save_file.save(save_path) # save
	read_save() # reread the empty values into the lists
