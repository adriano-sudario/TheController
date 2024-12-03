@tool
extends EditorPlugin

var loopitos
var editor_selection

const LOOPITOS_PATH = "res://addons/level_path_loader/level_path_loader_menu.tscn"

func _enter_tree():
	add_custom_type("Loopitos", "Node", preload("loopitos.gd"), preload("music.png"))
	add_custom_type("SampleGroup", "Resource", preload("models/sample_group.gd"), preload("pad.png"))

func _exit_tree():
	remove_custom_type("Loopitos")
	remove_custom_type("SampleGroup")
