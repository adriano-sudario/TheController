class_name State
extends Node

var connected_states:Array[ConnectedState] = []
var node:Node
var key:String
var machine:StateMachine

func _ready():
	key = StringExtension.pascal_case_to_snake_case(str(name))

func connect_state(state):
	var condition_method_name = "_" + state.key + "_condition"
		
	if not has_method(condition_method_name):
		return
	
	var connected_state = ConnectedState.new()
	connected_state.change_condition = get(condition_method_name)
	connected_state.value = state
	connected_states.append(connected_state)

func is_current():
	return machine.current_state == self

func machine_ready():
	pass

func enter():
	pass

func update(_delta):
	pass

func update_physics(_delta):
	pass

func exit():
	pass
