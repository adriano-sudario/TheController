class_name SpellProjectile
extends Node2D

@export var damage := 3.0
@export var speed := 150.0
@export var juicy_speed := 2

var sample_spell: InputSampleSpell

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var current_scale := scale

func _ready():
	scale = Vector2.ZERO

func _process(delta):
	position += transform.x * speed * delta
	scale = scale.lerp(Vector2.ONE * current_scale, delta * juicy_speed)

func _on_area_2d_body_entered(body):
	pass

func _on_area_2d_body_exited(body):
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
