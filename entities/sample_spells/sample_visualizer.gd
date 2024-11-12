class_name SampleVisualizer
extends Node2D

@export var radius := 10.0
@export var initial_angle_point := -90
@export var color := Color("478cbf")

var percent := 0.0:
	set(value):
		percent = value
		queue_redraw()

@onready var panel_container: PanelContainer = get_parent()

const POINTS_COUNT := 32

func update_armed(is_armed: bool):
	await ready
	
	if not is_armed:
		percent = 0.0
		panel_container.modulate.a = 0.3
	else:
		panel_container.modulate.a = 1.0

func draw_circle_sample_visualizer():
	var angle_from = initial_angle_point
	var angle_to = initial_angle_point + (360 * percent)
	
	var points_arc = PackedVector2Array()
	points_arc.push_back(position)
	
	for i in range(POINTS_COUNT + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / POINTS_COUNT)
		var point = position + Vector2(cos(angle_point), sin(angle_point)) * radius
		points_arc.push_back(point)
	
	draw_colored_polygon(points_arc, color)

func _draw():
	draw_circle_sample_visualizer()
