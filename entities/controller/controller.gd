class_name Controller
extends Node

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
var samples: Array[SampleSpell] = []
var samples_to_toggle_arm: Array[SampleSpell] = []
var current_stream := Stream.A:
	set(value):
		current_stream = value
		match (value):
			Stream.A:
				current_sync_stream = sync_stream_a
				current_audio_stream = audio_stream_player_a
			Stream.B:
				current_sync_stream = sync_stream_b
				current_audio_stream = audio_stream_player_b
			Stream.NULL:
				current_sync_stream = null
				current_audio_stream = null

const SLOT_ACTIONS := [
	"up_left_slot_press", "up_right_slot_press", "down_left_slot_press", "down_right_slot_press"
]

@onready var beats_per_second = 60.0 / bpm
@onready var audio_stream_player_a: AudioStreamPlayer2D = $AudioStreamPlayerA
@onready var audio_stream_player_b: AudioStreamPlayer2D = $AudioStreamPlayerB
@onready var sample_spells := $Spells.get_children().filter(func(s): return s is SampleSpell)
@onready var sync_stream_a: AudioStreamSynchronized = audio_stream_player_a.stream
@onready var sync_stream_b: AudioStreamSynchronized = audio_stream_player_b.stream
@onready var current_sync_stream := sync_stream_a
@onready var current_audio_stream := audio_stream_player_a
@onready var level := get_parent()
@onready var player: Player = level.get_node("Player")

func get_free_audio_stream():
	if current_audio_stream == audio_stream_player_b:
		return audio_stream_player_a
	
	return audio_stream_player_b

func get_free_stream():
	if current_stream == Stream.A:
		return Stream.B
	
	return Stream.A

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
	
	var visualizer = %SamplesContainer.get_node("%s/SampleVisualizer" % path_prefix)
	return visualizer as SampleVisualizer

func fill_sample_slot(sample: SampleSpell, slot: SampleSlot, stream: Stream = Stream.NULL):
	var audio_stream = null
	
	if sample != null:
		audio_stream = sample.audio
	
	match (stream):
		Stream.A:
			sync_stream_a.set_sync_stream(slot, audio_stream)
		Stream.B:
			sync_stream_b.set_sync_stream(slot, audio_stream)
		Stream.NULL:
			sample.visualizer = get_visualizer(slot)
			sample.controller = self
			sample.controller_slot = slot
			sample.is_armed = true
			sync_stream_a.set_sync_stream(slot, audio_stream)
			sync_stream_b.set_sync_stream(slot, audio_stream)

func toggle_sample_armed(sample: SampleSpell):
	set_sample_armed(sample, not sample.is_armed)

func set_sample_armed(sample: SampleSpell, is_armed: bool):
	sample.is_armed = is_armed
	
	if is_armed:
		fill_sample_slot(sample, sample.controller_slot, get_free_stream())
	else:
		sample.current_beat = 0
		sample.cicle_count = 0
		fill_sample_slot(null, sample.controller_slot, get_free_stream())
	
	toggle_stream()

func toggle_stream():
	var current_position = current_audio_stream.get_playback_position()
	var previous_stream = current_audio_stream
	get_free_audio_stream().play(current_position)
	previous_stream.stop()
	current_stream = get_free_stream()

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
	
	Debug.setup_node_variables(self, ["beat_count", "current_stream"])
	#beat_changed.connect(func(_beat): Debug.show_message("tuntz", .25))
	bars_cicled.connect(func():
		Debug.show_message("oxe kd", .25)
		
		if samples_to_toggle_arm.size() == 0:
			return
		
		for sample in samples_to_toggle_arm:
			toggle_sample_armed(sample)
		
		samples_to_toggle_arm.clear()
		)

func _process(_delta):
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
	
	var previous_beat = current_beat
	current_beat_float = get_current_beat_float()
	current_percent_between_beats = get_current_percent_between_beats(current_beat_float)
	current_beat = get_current_beat(current_beat_float)
	
	if current_beat != previous_beat:
		beat_count += 1
		beat_changed.emit(beat_count)
		
		if current_beat % bars == 0:
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
