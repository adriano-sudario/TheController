class_name SampleSelection
extends Control

@export var color: Color
@export var section := Controller.SampleSlot.UP_LEFT
@export var items: Array[SampleSelectResource]

var sample_select_containers := []
var is_selected := false
var hovered_column := 0
var hovered_row := 0
var hovered_index := 0
var loopitos := Loopitos.new()

var hovered_container: SampleSelectContainer:
	get(): return sample_select_containers[hovered_index]

var hovered_item: SampleSelectResource:
	get(): return items[hovered_index]
	
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var grid_columns: int = grid_container.columns

func _ready():
	loopitos.bpm = 140
	loopitos.tolerance = 0.25
	loopitos.perfect_tolerance = 0.15
	#loopitos.beat.connect(on_beat)
	add_child(loopitos)
	
	for item in items:
		var sample_select_container: SampleSelectContainer = load(
			"res://ui/sample_selection/sample_select_container.tscn").instantiate()
		sample_select_container.description = item.description
		sample_select_container.selected_color = color
		var sample_group := SampleGroup.new()
		sample_group.description = item.description
		sample_group.samples = [item.audio]
		item.sample_group = sample_group
		grid_container.add_child(sample_select_container)
		sample_select_containers.append(sample_select_container)
		loopitos.sample_groups.push_back(sample_group)
		sample_group.initial_setup(loopitos)
	
	#add_child(loopitos)
	loopitos.start()
	hovered_container.is_hovered = true

func _process(_delta):
	if Input.is_action_just_pressed("left"):
		hover_left()
	
	if Input.is_action_just_pressed("right"):
		hover_right()
	
	if Input.is_action_just_pressed("up"):
		hover_up()
	
	if Input.is_action_just_pressed("down"):
		hover_down()
	
	if Input.is_action_just_pressed("interact"):
		hovered_container.is_selected = not hovered_container.is_selected
		
		if hovered_container.is_selected:
			hovered_item.sample_group.play()
		else:
			hovered_item.sample_group.stop()

func hover_left():
	if hovered_row - 1 < 0 and grid_columns == 0:
		return false
	
	if hovered_row - 1 < 0:
		hovered_row = grid_columns - 1
		
		if not hover_up():
			hovered_row = 0
			return false
	else:
		hovered_row -= 1
	
	change_hover()
	return true

func hover_right():
	if get_grid_index(hovered_column, hovered_row + 1) >= items.size():
		return false
	
	if hovered_row + 1 >= grid_columns:
		hovered_row = 0
		
		if not hover_down():
			hovered_row = grid_columns - 1
			return false
	else:
		hovered_row += 1
	
	change_hover()
	return true

func hover_up():
	if hovered_column - 1 < 0:
		return false
	
	hovered_container.is_hovered = false
	hovered_column -= 1
	
	change_hover()
	return true

func hover_down():
	if get_grid_index(hovered_column + 1, hovered_row) >= items.size():
		return false
	
	hovered_container.is_hovered = false
	hovered_column += 1
	
	change_hover()
	return true

func change_hover():
	hovered_container.is_hovered = false
	hovered_index = get_grid_index(hovered_column, hovered_row)
	hovered_container.is_hovered = true

func get_grid_index(grid_column: int, grid_row: int):
	return (grid_column * grid_columns) + grid_row
