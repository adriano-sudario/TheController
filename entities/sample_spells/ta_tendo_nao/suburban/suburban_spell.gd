class_name SuburbanSpell
extends InputSampleSpell

@export var projectile: Resource

var fired_sunburn_projectiles: Array[SunburnProjectile]

func _on_triggered(_trigger_beat):
	if not is_armed:
		return
	
	var sunburn_projectile: SunburnProjectile = projectile.instantiate()
	sunburn_projectile.rotation = controller.rotation
	sunburn_projectile.position = controller.antenna_tip.global_position
	sunburn_projectile.sample_spell = self
	controller.level.add_child(sunburn_projectile)
	fired_sunburn_projectiles.append(sunburn_projectile)
	sunburn_projectile.tree_exited.connect(func(): fired_sunburn_projectiles.erase(sunburn_projectile))

func _on_triggered_by_input(_beat_pressed):
	for fired_sunburn in fired_sunburn_projectiles:
		fired_sunburn.explode()
