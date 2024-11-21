class_name Controller
extends Node2D

enum SampleSlot { UP_LEFT = 0, UP_RIGHT = 1, DOWN_LEFT = 2, DOWN_RIGHT = 3 }
enum Stream { A = 0, B = 1, NULL = -1 }

signal beat_changed(beat_count: float)
signal bars_cicled(beat_count: float)

@export var bpm := 120
@export var bars := 4

var current_beat := 0
var current_beat_float := 0.0
var current_percent_between_beats := 0.0
var beat_count := 0
var bars_cicle_count := 0
var samples: Array[SampleSpell] = []
var samples_to_toggle_arm: Array[SampleSpell] = []
var is_using_gamepad := false
#var aiming_angle := 0.0

const SLOT_ACTIONS := [
	"up_left_slot_press", "up_right_slot_press", "down_left_slot_press", "down_right_slot_press"
]

@onready var beats_per_second = 60.0 / bpm
@onready var current_audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer
@onready var sample_spells := current_audio_stream.get_children().filter(func(s): return s is SampleSpell)
@onready var current_sync_stream: AudioStreamSynchronized = current_audio_stream.stream
@onready var player: Player = get_parent()
@onready var level: Level = player.get_parent()
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var antenna_tip: Marker2D = $AntennaTip

func get_sample_by_slot(slot: SampleSlot) -> SampleSpell:
	return samples.filter(func(s: SampleSpell): return s.controller_slot == slot)[0]

func get_slot_action_name(slot: SampleSlot):
	return SLOT_ACTIONS[slot]

func get_visualizer(slot: SampleSlot) -> SampleVisualizer:
	var path_prefix := ""
	
	match (slot):
		SampleSlot.UP_LEFT:
			path_prefix = "SamplesPanel/SlotsContainer/UpSlotsContainer/UpLeftSlot"
		SampleSlot.UP_RIGHT:
			path_prefix = "SamplesPanel/SlotsContainer/UpSlotsContainer/UpRightSlot"
		SampleSlot.DOWN_LEFT:
			path_prefix = "SamplesPanel/SlotsContainer/DownSlotsContainer/DownLeftSlot"
		SampleSlot.DOWN_RIGHT:
			path_prefix = "SamplesPanel/SlotsContainer/DownSlotsContainer/DownRightSlot"
	
	var visualizer = level.get_node("SamplesContainer/%s/SampleVisualizer" % path_prefix)
	return visualizer as SampleVisualizer

func fill_sample_slot(sample: SampleSpell, slot: SampleSlot):
	sample.visualizer = get_visualizer(slot)
	sample.controller = self
	sample.controller_slot = slot
	sample.is_armed = true
	current_sync_stream.set_sync_stream(slot, sample.audio)

func toggle_sample_armed(sample: SampleSpell):
	set_sample_armed(sample, not sample.is_armed)

func set_sample_armed(sample: SampleSpell, is_armed: bool):
	sample.is_armed = is_armed
	
	if is_armed:
		current_sync_stream.set_sync_stream_volume(sample.controller_slot, 0.0)
	else:
		current_sync_stream.set_sync_stream_volume(sample.controller_slot, -60.0)

func stop():
	current_audio_stream.stop()
	current_beat = 0
	beat_count = 0
	
	for sample_spell in sample_spells:
			sample_spell.current_beat = 0
			sample_spell.cicle_count = 0

func get_current_beat(from_beat_float = null) -> int:
	if from_beat_float == null:
		return floor(current_audio_stream.get_playback_position() / beats_per_second)
	else:
		return floor(from_beat_float)

func get_current_beat_float() -> float:
	return current_audio_stream.get_playback_position() / beats_per_second

func get_current_percent_between_beats(from_beat_float = null) -> float:
	if from_beat_float == null:
		return get_current_beat_float() - get_current_beat()
	else:
		return from_beat_float - get_current_beat(from_beat_float)

func _ready():
	var sample_slots = SampleSlot.values()
	
	for sample_slot in SampleSlot.values():
		samples.append(null)
	
	var index := 0
	
	for sample in sample_spells:
		if index >= sample_slots.size():
			break
		
		samples[index] = sample
		fill_sample_slot(sample, index)
		index += 1
	
	Debug.setup_node_variables(self, ["rotation", "beat_count"])
	beat_changed.connect(func(_beat): Debug.show_message("tuntz %s" % current_beat, .25))
	bars_cicled.connect(func():
		#Debug.show_message("pei %s" % bars_cicle_count, .25)
		
		if samples_to_toggle_arm.size() == 0:
			return
		
		for sample in samples_to_toggle_arm:
			toggle_sample_armed(sample)
		
		samples_to_toggle_arm.clear()
		)

func _process(_delta):
	handle_inputs()
	
	if not current_audio_stream.playing:
		return
	
	handle_beats()

func handle_beats():
	var previous_beat = current_beat
	current_beat_float = get_current_beat_float()
	current_percent_between_beats = get_current_percent_between_beats(current_beat_float)
	current_beat = get_current_beat(current_beat_float)
	
	if current_beat != previous_beat:
		beat_count += 1
		beat_changed.emit(beat_count)
		
		if current_beat % bars == 0:
			bars_cicle_count += 1
			bars_cicled.emit()
		
		for sample_spell in sample_spells:
			sample_spell.current_beat += 1
			
			if sample_spell.current_beat >= sample_spell.total_beats:
				sample_spell.cicle_count += 1
				sample_spell.beat_cicle_completed.emit()
				sample_spell.current_beat = 0
			
			for trigger_beat in sample_spell.trigger_beats:
				if sample_spell.current_beat == trigger_beat - 1:
					sample_spell.triggered.emit(trigger_beat)
					break
	else:
		for sample_spell in sample_spells:
			for trigger_beat in sample_spell._trigger_beats_float:
				var sample_beat_float = sample_spell.current_beat + current_percent_between_beats
				
				if sample_beat_float >= trigger_beat - 1:
					sample_spell.triggered.emit(trigger_beat)
					break

func handle_inputs():
	if Input.is_action_just_pressed("interact"):
		if current_audio_stream.playing:
			stop()
		else:
			current_audio_stream.play()
	
	if not current_audio_stream.playing:
		return
	
	if Input.is_action_pressed("arm_toggle"):
		for i in range(SLOT_ACTIONS.size()):
			if Input.is_action_just_pressed(get_slot_action_name(i)):
				var sample = get_sample_by_slot(i)
				
				if samples_to_toggle_arm.has(sample):
					samples_to_toggle_arm.erase(sample)
				else:
					samples_to_toggle_arm.append(sample)
	
	if is_using_gamepad:
		var axis_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var axis_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		#aiming_angle = Vector2(axis_x, axis_y).angle()
		rotation = Vector2(axis_x, axis_y).angle()
	else:
		#aiming_angle = global_position.angle_to(get_global_mouse_position())
		look_at(get_global_mouse_position())
		#aiming_angle = rotation
	
	#rotation = aiming_angle

func _input(event):
	is_using_gamepad = event is InputEventJoypadButton or event is InputEventJoypadMotion
	
	#if is_using_gamepad:
		#return
	#
	#if event is InputEventMouse:
		#var mouse_event := event as InputEventMouse
		#aiming_angle = global_position.angle_to(mouse_event.position)
