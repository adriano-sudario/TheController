@tool
class_name ProcoratoField
extends Node2D

@export var damage := 0.5
@export var radius = 100.0:
	set(value):
		radius = value
		adjust_size()

var target_on_range: Enemy

@onready var shockwave_distortion:Panel = $ShockwaveDistortion
@onready var style_box := shockwave_distortion.get_theme_stylebox("panel") as StyleBoxFlat
@onready var collision_shape:CollisionShape2D = $Area2D/CollisionShape2D
@onready var shape:CircleShape2D = collision_shape.shape

func _ready():
	adjust_position()

func adjust_position():
	shockwave_distortion.position = -((shockwave_distortion.size * shockwave_distortion.scale) / 2)

func adjust_size():
	if shape == null:
		await ready
	
	shape.radius = radius
	var panel_size = radius * 2.0
	var panel_borders_size := int(panel_size / 4)
	shockwave_distortion.size = Vector2.ONE * panel_size
	style_box.corner_radius_top_left = panel_borders_size
	style_box.corner_radius_top_right = panel_borders_size
	style_box.corner_radius_bottom_left = panel_borders_size
	style_box.corner_radius_bottom_right = panel_borders_size

func _process(_delta):
	if target_on_range == null:
		return
	
	target_on_range.get_hit(damage)

func _on_area_2d_body_entered(body):
	if body is Enemy:
		target_on_range = body

func _on_area_2d_body_exited(body):
	if body is Enemy:
		target_on_range = null
