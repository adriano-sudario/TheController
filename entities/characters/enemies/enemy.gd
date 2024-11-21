class_name Enemy
extends StaticBody2D

@export var hp := 1.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func get_hit(damage = 1.0):
	hp -= damage
	
	if hp > 0:
		if animated_sprite.frame >= 4:
			animated_sprite.frame = 0
		
		animated_sprite.play("hit")
	else:
		queue_free()
