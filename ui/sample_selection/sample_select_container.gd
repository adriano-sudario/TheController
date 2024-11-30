class_name SampleSelectContainer
extends PanelContainer

@export var description := ""
@export var selected_color: Color

var is_hovered: bool:
	set(value):
		is_hovered = value
		
		if style_box == null:
			await ready
		
		if is_hovered:
			style_box.border_color.a = 1.0
		else:
			style_box.border_color.a = 0.3

var is_selected := false:
	set(value):
		is_selected = value
		
		if style_box == null:
			await ready
		
		if is_selected:
			style_box.border_color = selected_color
		else:
			style_box.border_color = unselected_color

@onready var label = $Label
@onready var style_box := get_theme_stylebox("panel") as StyleBoxFlat
@onready var unselected_color := style_box.border_color

func _ready():
	is_hovered = false
	var cloned_theme := style_box.duplicate()
	add_theme_stylebox_override("panel", cloned_theme)
	style_box = cloned_theme
	label.text = description
