@icon("pad.png")
class_name SampleGroup
extends Resource

signal cycle_complete

@export var description: String
@export var samples: Array[AudioStream]
@export_range(0.0, 1.0, .01) var volume := 1.0

var player: AudioStreamPlayer = AudioStreamPlayer.new()
var loopitos: Loopitos
var total_beats:float
var beats_count := 0
var cycles_count := 0
var length := 0.0

var current_sample: AudioStream:
	set(value):
		current_sample = value
		
		if current_sample == null:
			return
		
		length = current_sample.get_length()
		total_beats = round(current_sample.get_length() / loopitos.beats_per_second)

var is_looping: bool:
	set(value):
		is_looping = value
		
		if value and not player.is_connected("finished", play):
			player.finished.connect(play)
		elif not value and player.is_connected("finished", play):
			player.finished.disconnect(play)

func initial_setup(owner: Loopitos):
	loopitos = owner
	current_sample = samples[0]
	player.stream = current_sample
	is_looping = true
	loopitos.add_child(player)

func change_sample(index: int):
	if current_sample == samples[index]:
		return
	
	current_sample = samples[index]
	var position = player.get_playback_position()
	player.stream = current_sample
	player.play(position)

func play():
	player.play()

func stop():
	player.stop()
