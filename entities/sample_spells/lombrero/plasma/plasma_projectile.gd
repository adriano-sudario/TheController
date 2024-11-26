class_name PlasmaProjectile
extends Node2D

@export var damage := 3.0
@export var speed := 150.0
@export var juicy_speed := 2

var sample_spell: InputSampleSpell
var has_exploded := false
var enemies_on_range := []
var enemies_hit := []
var beats_duration := 0.0
var elapsed_beats := 0:
	set(value):
		if has_exploded:
			return
		
		elapsed_beats = value
		
		if elapsed_beats >= beats_duration:
			explode()

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var current_scale := scale

func _ready():
	scale = Vector2.ZERO

func _process(delta):
	position += transform.x * speed * delta
	scale = scale.lerp(Vector2.ONE * current_scale, delta * juicy_speed)

func explode():
	if has_exploded:
		return
	
	animated_sprite.animation_finished.connect(func(): queue_free())
	animated_sprite.play("explode")
	has_exploded = true
	
	for enemy: Enemy in enemies_on_range:
		enemy.get_hit(damage)
		enemies_hit.append(enemy)

func _on_area_2d_body_entered(body):
	if body is not Enemy or enemies_hit.has(body):
		return
	
	enemies_on_range.append(body)

func _on_area_2d_body_exited(body):
	enemies_on_range.erase(body)
