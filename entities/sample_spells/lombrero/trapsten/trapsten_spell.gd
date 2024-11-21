class_name TrapstenSpell
extends InputSampleSpell

@export var projectile: Resource
@export var special_projectile: Resource

var is_shooting_kunais := false

func _on_triggered(_trigger_beat):
	if not is_armed or is_shooting_kunais:
		return
	
	spawn_projectile(TrapstenProjectile.TrapstenType.SHURIKEN)

func _on_triggered_by_input(_trigger_beat):
	await get_tree().create_timer(controller.beats_per_second).timeout
	
	is_shooting_kunais = true
	var spawn_interval = controller.beats_per_second / 8
	
	for i in range(8):
		spawn_projectile(TrapstenProjectile.TrapstenType.KUNAI)
		await get_tree().create_timer(spawn_interval).timeout
	
	is_shooting_kunais = false

func spawn_projectile(type: TrapstenProjectile.TrapstenType):
	var trapsten_projectile: TrapstenProjectile = projectile.instantiate()
	trapsten_projectile.global_position = controller.antenna_tip.global_position
	trapsten_projectile.type = type
	trapsten_projectile.target = NodeExtension.find_closest_node_to_point2d(
		controller.level.enemies, trapsten_projectile.position)
	trapsten_projectile.sample_spell = self
	controller.level.add_child(trapsten_projectile)
