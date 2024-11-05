class_name StateMachine
extends Node

@onready var node:Node = get_parent()

@export var initial_state:State

var dictionary:Dictionary = {}
var current_state:State

func _ready():
	var state_children = get_children().filter(func(state): return state is State)
	
	for state in state_children:
		state.node = node
		state.machine = self
		
		for s in state_children:
			if s == state:
				continue
			
			state.connect_state(s)
		
		dictionary[state.key] = state
	
	if not initial_state:
		push_warning("You must assign an initial state on a StateMachine, otherwise it will be set as the first child")
		initial_state = state_children[0]
	
	change_state(initial_state)
	
	await node.ready
	
	for state in state_children:
		state.machine_ready()

func change_state(_state:State):
	if _state == current_state:
		return
	
	if current_state != null:
		current_state.exit()
	
	_state.enter()
	current_state = _state

func change_state_string(_state:String):
	change_state(dictionary[_state])

func check_state_change():
	for connected_state in current_state.connected_states:
		if connected_state.change_condition.call():
			change_state(connected_state.value)
			break

func _process(delta):
	if not current_state:
		return
	
	current_state.update(delta)
	check_state_change()
