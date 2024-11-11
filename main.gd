extends Node3D

@onready var controller: Controller = $Controller

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if controller.current_audio_stream.playing:
			controller.stop()
		else:
			controller.current_audio_stream.play()
