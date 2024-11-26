extends Line2D

@export var spread_angle := PI/4.0 # (float, 0.5, 3.0)
@export var segments := 12 # (int, 1, 36)

var start: Vector2
var end: Vector2
var duration: float = 0.1

@onready var sparks := $Sparks

func _ready() -> void:
	set_as_top_level(true)
	create()

func create() -> void:
	sparks.emitting = true
	
	var _points := []
	var _current := start
	var _segment_length := start.distance_to(end) / segments
	_points.append(start)
	
	for segment in range(segments):
		var _rotation := randf_range(-spread_angle / 2, spread_angle / 2)
		var _new := _current + (_current.direction_to(end) * _segment_length).rotated(_rotation)
		_points.append(_new)
		_current = _new
	
	_points.append(end)
	points = _points
	sparks.global_position = end
	var tween: Tween = create_tween()
	tween.tween_property(self, "self_modulate", Color(1, 1, 1, 0), duration)
	tween.tween_callback(queue_free)
