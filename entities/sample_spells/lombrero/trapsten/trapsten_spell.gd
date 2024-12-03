class_name TrapstenSpell
extends InputSampleSpell

@export var projectile: Resource

var is_shooting_kunais := false
var prevent_next_throw := false

func _on_triggered(_trigger_beat):
	if prevent_next_throw:
		prevent_next_throw = false
		return
	
	if not is_armed or is_shooting_kunais:
		return
	
	spawn_projectile(TrapstenProjectile.TrapstenType.SHURIKEN)

func _on_succeeded(_beat_pressed):
	if not is_armed or is_shooting_kunais:
		return
	
	await get_tree().create_timer(controller.beats_per_second).timeout
	
	is_shooting_kunais = true
	var spawn_interval = controller.beats_per_second / 8
	
	for i in range(8):
		spawn_projectile(TrapstenProjectile.TrapstenType.KUNAI)
		await get_tree().create_timer(spawn_interval).timeout
	
	is_shooting_kunais = false

func _on_missed():
	prevent_next_throw = true

func spawn_projectile(type: TrapstenProjectile.TrapstenType):
	var trapsten_projectile: TrapstenProjectile = projectile.instantiate()
	trapsten_projectile.global_position = controller.antenna_tip.global_position
	trapsten_projectile.type = type
	trapsten_projectile.target = NodeExtension.find_closest_node_to_point2d(
		controller.level.enemies, trapsten_projectile.global_position)
	trapsten_projectile.sample_spell = self
	controller.level.add_child(trapsten_projectile)
