class_name TrapstenProjectile
extends Node2D

enum TrapstenType { SHURIKEN, KUNAI }

@export var shuriken_damage := 3.0
@export var kunai_damage := 1.0
@export var rotation_speed := 25.0
@export var type := TrapstenType.SHURIKEN

var sample_spell: InputSampleSpell
var target: Enemy
var damage := 0.0
var elapsed_time := 0.0
var duration := 0.0
var initial_position: Vector2

@onready var sprite = $AnimatedSprite2D
@onready var current_scale := scale

func _ready():
	match (type):
		TrapstenType.SHURIKEN:
			damage = shuriken_damage
			sprite.play("shuriken")
		TrapstenType.KUNAI:
			damage = kunai_damage
			sprite.play("kunai")
			look_at(target.global_position)
	
	duration = sample_spell.controller.beats_per_second
	initial_position = global_position

func _process(delta):
	elapsed_time += delta
	global_position = Tween.interpolate_value(
		initial_position, target.global_position - initial_position, elapsed_time, duration,
		Tween.TransitionType.TRANS_LINEAR, Tween.EaseType.EASE_IN_OUT)
	
	if elapsed_time >= duration:
		elapsed_time = 0.0
	
	if target == null or type == TrapstenType.KUNAI:
		return
	
	sprite.rotation += delta * rotation_speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_2d_body_entered(body):
	if body is not Enemy:
		return
	
	var enemy = body as Enemy
	enemy.get_hit(damage)
	queue_free()
