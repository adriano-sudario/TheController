class_name SunburnProjectile
extends Node2D

@export var damage := 3.0
@export var speed := 150.0

var sample_spell: InputSampleSpell
var has_exploded := false
var enemies_on_range := []
var enemies_hit := []

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta):
	position += transform.x * speed * delta

func explode():
	if has_exploded:
		return
	
	animated_sprite.animation_finished.connect(func(): queue_free())
	animated_sprite.play("explode")
	has_exploded = true
	
	for enemy: Enemy in enemies_on_range:
		if enemy is Dummy:
			enemy.get_hit(0)
		else:
			enemy.get_hit(damage)
		
		enemies_hit.append(enemy)

func _on_area_2d_body_entered(body):
	if body is not Enemy or enemies_hit.has(body):
		return
	
	enemies_on_range.append(body)

func _on_area_2d_body_exited(body):
	enemies_on_range.erase(body)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
