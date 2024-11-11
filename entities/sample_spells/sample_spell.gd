class_name SampleSpell
extends Node

signal triggered(trigger_beat: float)
signal beat_cicle_completed

@export var audio: AudioStreamMP3
@export var trigger_beats: Array[float] = []
@export var include_trigger_on_bar := -1

var controller: Controller
var controller_slot: Controller.SampleSlot
var visualizer: SampleVisualizer
var current_beat := 0
var cicle_count := 0
var _trigger_beats_float: Array[float] = []
var _triggered_beats_float: Array[float] = []

@onready var total_beats = audio.beat_count

func _ready():
	if include_trigger_on_bar > 0:
		for i in range(total_beats):
			if i % include_trigger_on_bar == 0:
				trigger_beats.append(i + 1)
	else:
		for i in range(trigger_beats.size()):
			if is_equal_approx(trigger_beats[i], roundf(trigger_beats[i])):
					continue
			_trigger_beats_float.append(trigger_beats[i])
		
		triggered.connect(func(trigger_beat):
			_trigger_beats_float.erase(trigger_beat)
			_triggered_beats_float.append(trigger_beat))
		beat_cicle_completed.connect(func():
			for i in range(_triggered_beats_float.size()):
				_trigger_beats_float.append(_triggered_beats_float[i])
			_triggered_beats_float.clear())
	
	triggered.connect(func(beat): Debug.show_message("%s ~ %.2f" % [name, beat], .25))

func _process(_delta):
	if not controller.current_audio_stream.playing:
		return
	
	var current_beat_float = current_beat + controller.get_current_percent_between_beats()
	visualizer.percent = current_beat_float / total_beats
