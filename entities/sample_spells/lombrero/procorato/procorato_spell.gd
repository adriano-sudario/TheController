class_name ProcoratoSpell
extends SampleSpell

@export var procorato_field_resource: Resource

var procorato_field: ProcoratoField

func _ready():
	super._ready()
	
	if is_playing:
		spawn_procorato_field()

func _process(delta):
	super._process(delta)
	
	if is_playing and procorato_field == null:
		spawn_procorato_field()
	
	if not is_playing and procorato_field != null:
		remove_procorato_field()
	
	if procorato_field == null:
		return
	
	procorato_field.global_position = controller.player.global_position

func spawn_procorato_field():
	procorato_field = procorato_field_resource.instantiate()
	procorato_field.global_position = controller.player.global_position
	controller.level.add_child(procorato_field)
	
	var index = 0
	
	for child in controller.level.get_children():
		if child is Player:
			break
		
		index += 1
	
	controller.level.move_child(procorato_field, index)

func remove_procorato_field():
	controller.level.remove_child(procorato_field)
	procorato_field = null
