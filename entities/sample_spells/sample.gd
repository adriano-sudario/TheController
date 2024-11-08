class_name SampleSpell
extends Node

signal triggered

@export var audio: AudioStreamMP3
@export var trigger_entity: Resource

#var bpm: float

#@onready var beats_per_second = 60.0 / audio.bpm
#
#func get_current_beat() -> int:
	#return floor(audio.get_playback_position() / beats_per_second)
#
#func get_current_beat_float() -> float:
	#return audio.get_playback_position() / beats_per_second
#
#func get_current_percent_between_beats() -> float:
	#return get_current_beat_float() - get_current_beat()
