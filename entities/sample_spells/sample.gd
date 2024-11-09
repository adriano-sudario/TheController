class_name SampleSpell
extends Node

signal triggered(trigger_beat: float)
signal beat_cicle_completed

@export var audio: AudioStreamMP3
@export var trigger_beats: Array[float] = []
@export var include_trigger_on_bar := -1

var controller: Controller
var visualizer: SampleVisualizer
var current_beat := 0
var cicle_count := 0

@onready var total_beats = audio.beat_count

func _ready():
	if include_trigger_on_bar > 0:
		for i in range(total_beats):
			if i % include_trigger_on_bar == 0:
				trigger_beats.append(i + 1)
	
	triggered.connect(func(beat): Debug.show_message("%s ~ %d" % [name, beat], .25))
	beat_cicle_completed.connect(func(): Debug.show_message("%s VIRATED ~ %d" % [name, cicle_count], .25))

func _process(_delta):
	if not controller.current_audio_stream.playing:
		return
	
	var current_beat_float = current_beat + controller.get_current_percent_between_beats()
	visualizer.percent = current_beat_float / total_beats
