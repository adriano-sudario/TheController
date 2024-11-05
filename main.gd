extends Node3D

func _ready():
	$AudioStreamPlayer2D.playing = true
	var hm: AudioStreamSynchronized = $AudioStreamPlayer2D.stream
	var kd: AudioStream = hm.get_sync_stream(0)
	#hm.set_sync_stream(0, null)
	var hein = true

func _on_audio_stream_player_2d_finished():
	print("hm")
