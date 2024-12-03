@icon("music.png")
class_name Loopitos
extends Node

enum HIT { MISSED, OK, PERFECT }

signal beat

@export var bpm: float
@export var tolerance := .1
@export var perfect_tolerance := .05
@export var sample_groups: Array[SampleGroup] = []

var beats_per_second:float
var elapsed_time := 0.0
var beats_count := 0
var has_started := false

func get_current_beat() -> int:
	return floor(elapsed_time / beats_per_second)

func get_current_beat_float() -> float:
	return elapsed_time / beats_per_second

func get_current_percent_between_beats() -> float:
	return get_current_beat_float() - get_current_beat()

func is_hit_success(_beat: float, _tolerance: float) -> bool:
	var current_beat = get_current_beat_float()
	return current_beat >= _beat - _tolerance and current_beat <= _beat + _tolerance

func get_hit(_beat: float = -1.0) -> HIT:
	if _beat < 0:
		_beat = round(get_current_beat_float())
	
	if is_hit_success(_beat, perfect_tolerance):
		return HIT.PERFECT
	
	if is_hit_success(_beat, tolerance):
		return HIT.OK
	
	return HIT.MISSED

func on_beat(_current_beat: float):
	for sample_group in sample_groups:
		sample_group.beats_count += 1
		
		if sample_group.beats_count >= sample_group.total_beats and sample_group.is_looping:
			sample_group.beats_count = 0
			sample_group.cycles_count += 1
			
			if sample_group.player.playing:
				sample_group.player.seek(0.0)
			else:
				sample_group.player.play()
			
			sample_group.cycle_complete.emit()

func start(autoplay := true):
	has_started = true
	
	if autoplay:
		for sample_group in sample_groups:
			sample_group.player.play()

func _ready():
	beats_per_second = 60.0 / bpm
	beat.connect(on_beat)
	
	for sample_group in sample_groups:
		sample_group.initial_setup(self)

func _process(delta):
	if not has_started:
		return
	
	elapsed_time += delta
	var current_beat = get_current_beat()
	
	if current_beat > beats_count:
		beats_count += 1
		beat.emit(beats_count)
	
	if Input.is_action_just_pressed("ui_accept") and not get_hit() == HIT.MISSED:
		pass
