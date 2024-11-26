class_name Player
extends CharacterBody2D

@export var speed = 200.0

var is_stunned := false
var direction := Vector2.ZERO
var orientation := "down"
var is_flipped:bool = false:
	set(value):
		var previous_value = is_flipped
		is_flipped = value
		animated_sprite.flip_h = is_flipped
		
		if previous_value == value:
			return
		
		collision_shape.position.x = abs(collision_shape.position.x) * -sign(collision_shape.position.x)
		controller.position.x = abs(controller.position.x) * -sign(controller.position.x)
		#controller.sprite_2d.flip_h = is_flipped

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var controller: Controller = $Controller

func _process(_delta):
	direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	if Input.is_action_just_pressed("interact"):
		if controller.current_audio_stream.playing:
			controller.stop()
			animated_sprite.speed_scale = 1.0
		else:
			controller.current_audio_stream.play()
			animated_sprite.speed_scale = 0.0

func _physics_process(_delta):
	handle_move()
	handle_animation()

func handle_move():
	if is_stunned:
		return
	
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
	if controller.current_audio_stream.playing:
		var current_percent_between_beats = controller.get_current_percent_between_beats()
		var frames_count := 0
		
		if direction == Vector2.ZERO:
			animated_sprite.play("idle")
			frames_count = animated_sprite.sprite_frames.get_frame_count("idle")
			animated_sprite.frame = floor(frames_count * current_percent_between_beats)
			return
		
		animated_sprite.play("moving")
		var current_beat = controller.get_current_beat()
		frames_count = animated_sprite.sprite_frames.get_frame_count("moving")
		var half_frames_count = int(frames_count / 2.0)
		animated_sprite.frame = floor(half_frames_count * current_percent_between_beats)
		
		if current_beat % 2 != 0:
			animated_sprite.frame += half_frames_count
		
		return
	
	if direction == Vector2.ZERO:
		animated_sprite.play("idle")
		return
	
	animated_sprite.play("moving")
	#is_flipped = direction.x < 0
