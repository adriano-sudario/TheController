extends Node3D

@onready var controller: Controller = $Controller

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if controller.current_audio_stream.playing:
			controller.stop()
		else:
			controller.current_audio_stream.play()
	
	if Input.is_action_just_pressed("up_right_slot_press"):
		var hm = SampleSpell.new()
		
		if controller.get_free_stream() == 1:
			hm.audio = load("res://sounds/sample_kits/ta_tendo_nao/guitarrinha1.mp3")
		else:
			hm.audio = null
		
		controller.fill_sample_slot(hm, Controller.SampleSlot.UP_LEFT, controller.get_free_stream())
		controller.toggle_stream()
		
