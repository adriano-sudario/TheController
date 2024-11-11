class_name Player
extends CharacterBody2D

@export var speed = 200.0

var direction := Vector2.ZERO
var orientation := "down"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta):
	direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()

func _physics_process(_delta):
	handle_move()
	handle_animation()

func handle_move():
	if direction.x != 0:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction.y != 0:
		velocity.y = direction.y * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	move_and_slide()

func handle_animation():
	if direction == Vector2.ZERO:
		animated_sprite.play("idle_%s" % orientation)
		return
	
	orientation = get_direction_string(direction)
	
	if direction.x < 0:
		animated_sprite.play("walk_%s" % orientation)
	elif direction.x > 0:
		animated_sprite.play("walk_%s" % orientation)
	elif direction.y < 0:
		animated_sprite.play("walk_%s" % orientation)
	elif direction.y > 0:
		animated_sprite.play("walk_%s" % orientation)

func get_direction_string(_direction):
	if _direction.x < 0:
		return "left"
	
	if _direction.x > 0:
		return "right"
	
	if _direction.y < 0:
		return "up"
	
	if _direction.y > 0:
		return "down"
