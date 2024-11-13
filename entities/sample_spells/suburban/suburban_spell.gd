class_name SuburbanSpell
extends InputSampleSpell

var fired_sunburn_projectiles: Array[SunburnProjectile]

@onready var sunburn_resource := load("res://entities/sample_spells/suburban/sunburn_projectile.tscn")

func _on_triggered(_trigger_beat):
	if not is_armed:
		return
	
	var sunburn_projectile: SunburnProjectile = sunburn_resource.instantiate()
	var direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	sunburn_projectile.rotation = direction.angle()
	sunburn_projectile.position = controller.player.global_position
	sunburn_projectile.sample_spell = self
	controller.level.add_child(sunburn_projectile)
	fired_sunburn_projectiles.append(sunburn_projectile)
	sunburn_projectile.tree_exited.connect(func(): fired_sunburn_projectiles.erase(sunburn_projectile))

func _on_triggered_by_input():
	for fired_sunburn in fired_sunburn_projectiles:
		fired_sunburn.explode()
