class_name PlasmaSpell
extends InputSampleSpell

@export var projectile: Resource
@export var min_projectile_beats_duration := 2
@export var max_projectile_beats_duration := 6

var plasma_projectiles: Array[PlasmaProjectile]

func _on_triggered(_trigger_beat):
	if not is_armed:
		return
	
	for plasma in plasma_projectiles:
		plasma.elapsed_beats += 1
	
	var plasma_projectile: PlasmaProjectile = projectile.instantiate()
	plasma_projectile.rotation = controller.rotation
	plasma_projectile.position = controller.antenna_tip.global_position
	plasma_projectile.sample_spell = self
	plasma_projectile.beats_duration = randi_range(
		min_projectile_beats_duration, max_projectile_beats_duration)
	controller.level.add_child(plasma_projectile)
	plasma_projectiles.append(plasma_projectile)
	plasma_projectile.tree_exited.connect(func(): plasma_projectiles.erase(plasma_projectile))

func _on_succeeded(_beat_pressed):
	if not is_armed:
		return
	
	for plasma in plasma_projectiles:
		plasma.explode()

func _on_missed():
	for plasma in plasma_projectiles:
		plasma.queue_free()
