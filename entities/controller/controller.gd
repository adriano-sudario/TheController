class_name Controller
extends AudioStreamPlayer2D

enum SampleSlot { UP_LEFT = 0, UP_RIGHT = 1, DOWN_LEFT = 2, DOWN_RIGHT = 3 }
enum StreamClip { A = 0, B = 1, NULL = -1 }

signal beat_changed(beat_count: float)

@export var bpm := 120

var current_beat := 0
var beat_count := 0
var samples: Array[SampleSpell] = []

@onready var interactive_stream: AudioStreamInteractive = stream
@onready var sync_stream_a: AudioStreamSynchronized = interactive_stream.get_clip_stream(StreamClip.A)
@onready var sync_stream_b: AudioStreamSynchronized = interactive_stream.get_clip_stream(StreamClip.B)
@onready var current_clip := interactive_stream.initial_clip
@onready var beats_per_second = 60.0 / bpm

func get_free_clip():
	if current_clip == StreamClip.A:
		return StreamClip.B
	
	return StreamClip.A

func get_clip_string(clip: StreamClip):
	match (clip):
		StreamClip.A:
			return "a"
		StreamClip.B:
			return "b"

func fill_sample_slot(sample: SampleSpell, slot: SampleSlot, clip: StreamClip = StreamClip.NULL):
	var audio_stream = null
	
	if sample != null:
		audio_stream = sample.audio
	
	match (clip):
		StreamClip.A:
			sync_stream_a.set_sync_stream(slot, audio_stream)
		StreamClip.B:
			sync_stream_b.set_sync_stream(slot, audio_stream)
		StreamClip.NULL:
			sync_stream_a.set_sync_stream(slot, audio_stream)
			sync_stream_b.set_sync_stream(slot, audio_stream)

func toggle_clip():
	var clip_switch = get_free_clip()
	set("parameters/switch_to_clip", get_clip_string(clip_switch))
	current_clip = clip_switch

func get_current_beat() -> int:
	return floor(get_playback_position() / beats_per_second)

func get_current_beat_float() -> float:
	return get_playback_position() / beats_per_second

func get_current_percent_between_beats() -> float:
	return get_current_beat_float() - get_current_beat()

func _ready():
	var sample_slots = SampleSlot.values()
	
	for sample_slot in SampleSlot.values():
		samples.append(null)
	
	var index := 0
	
	for sample in get_children():
		if sample is not SampleSpell:
			continue
		
		if index >= sample_slots.size():
			break
		
		samples[index] = sample
		fill_sample_slot(sample, index)
		index += 1
	
	interactive_stream.add_transition(StreamClip.A, StreamClip.B,
		AudioStreamInteractive.TRANSITION_FROM_TIME_IMMEDIATE,
		AudioStreamInteractive.TRANSITION_TO_TIME_SAME_POSITION,
		AudioStreamInteractive.FADE_AUTOMATIC, 0)
	interactive_stream.add_transition(StreamClip.B, StreamClip.A,
		AudioStreamInteractive.TRANSITION_FROM_TIME_IMMEDIATE,
		AudioStreamInteractive.TRANSITION_TO_TIME_SAME_POSITION,
		AudioStreamInteractive.FADE_AUTOMATIC, 0)
	
	Debug.setup_node_variables(self, ["beat_count"])
	beat_changed.connect(func(_beat): Debug.show_message("tuntz", .25))

func _process(_delta):
	var previous_beat = current_beat
	current_beat = get_current_beat()
	
	if current_beat != previous_beat:
		beat_count += 1
		beat_changed.emit(beat_count)
