class_name InputSampleSpell
extends SampleSpell

signal triggered_by_input()

@export var input_trigger_beats: Array[float] = []
@export var include_input_trigger_on_bar := 4
@export var input_trigger_threshold := 0.25

func get_slot_action_name():
	return controller.get_slot_action_name(controller_slot)

func has_input_press_succeeded() -> bool:
	var beat = controller.current_beat_float
	
	for trigger_beat in input_trigger_beats:
		if beat >= trigger_beat - input_trigger_threshold and beat <= trigger_beat + input_trigger_threshold:
			return true
	
	return false

func _ready():
	super._ready()
	
	if include_input_trigger_on_bar > 0:
		for i in range(total_beats):
			if i % include_input_trigger_on_bar == 0:
				input_trigger_beats.append(i + 1)

func _process(delta):
	super._process(delta)
	
	if not is_playing and not Input.is_action_pressed("arm_toggle"):
		return
	
	if Input.is_action_just_pressed(get_slot_action_name()) and has_input_press_succeeded():
		triggered_by_input.emit()
