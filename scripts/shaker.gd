class_name Shaker
extends Node

var random := RandomNumberGenerator.new()
var duration := 0.2
var amplitude := Vector2(5.0, 5.0)
var timer := 0.0
var auto_shake := true
var initial_position: Vector2
var target: Node

func _ready():
	target = get_parent()
	random.randomize()
	
	if auto_shake:
		shake()

func _process(delta):
	if timer <= 0:
		target.position = initial_position
		queue_free()
		return
	
	timer -= delta
	
	if timer < 0:
		timer = 0.0
	
	update_shake(timer)

func update_shake(remaining_time: float):
	var scaled_time = remaining_time / duration
	var scaled_shake = Vector2(scaled_time * amplitude.x, scaled_time * amplitude.y)
	var random_x = random.randf_range(-scaled_shake.x, scaled_shake.x)
	var random_y = random.randf_range(-scaled_shake.y, scaled_shake.y)
	target.position = initial_position + Vector2(random_x, random_y)

func shake():
	if target == null:
		return
	
	initial_position = target.position
	timer = duration
