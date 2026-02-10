extends Node2D

signal particles_finished


func _ready() -> void:
	$GPUParticles2D.emitting = true # start emitting


func _on_gpu_particles_2d_finished() -> void:
	queue_free() # remove itself when finished
