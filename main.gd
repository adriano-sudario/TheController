class_name Level
extends Node2D

var enemies := []

@onready var player = $Player
@onready var samples_container = %SamplesContainer
@onready var bg = $BG

func _ready():
	enemies = NodeExtension.filter_children(self, func(child):
		if child is Enemy:
			child.tree_exited.connect(func(): enemies.erase(child))
			return true
		
		return false)
	var half_screen = get_viewport_rect().size * 0.5
	samples_container.position = Vector2(half_screen.x, 15)
	bg.position = half_screen

#func get_camera_rect() -> Rect2:
	#var camera_position = camera_2d.position
	#var half_size = (get_viewport_rect().size * 0.5) / camera_2d.zoom
	#return Rect2(camera_position - half_size, camera_position + half_size)
