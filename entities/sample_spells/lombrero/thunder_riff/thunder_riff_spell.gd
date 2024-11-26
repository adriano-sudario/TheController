class_name ThunderRiffSpell
extends InputSampleSpell

@export var projectile: Resource
@export var stun_beats_duration := 1.0
@export var additional_enemies_count_on_input_succeeded := 1

@onready var lightning_beam: LightningBeam = $LightningBeam

func _on_triggered(_trigger_beat):
	shoot_beam()

func _on_succeeded(_beat_pressed):
	shoot_beam(additional_enemies_count_on_input_succeeded)

func _on_missed():
	controller.player.is_stunned = true
	await get_tree().create_timer(controller.beats_per_second * stun_beats_duration).timeout
	controller.player.is_stunned = false

func shoot_beam(additional_enemies_count := 0):
	lightning_beam.flash_time = controller.beats_per_second / 8
	lightning_beam.global_position = controller.antenna_tip.global_position
	lightning_beam.target = NodeExtension.find_closest_node_to_point2d(
		controller.level.enemies, lightning_beam.global_position)
	
	if additional_enemies_count > 0:
		var previous_enemy = lightning_beam.target
		lightning_beam.additional_targets = []
		
		for i in range(additional_enemies_count):
			var enemies = controller.level.enemies.filter(func(e): return e != previous_enemy)
			var included_target: Enemy = NodeExtension.find_closest_node_to_point2d(
				enemies, previous_enemy.global_position)
			lightning_beam.additional_targets.append(included_target)
			previous_enemy = included_target
	
	lightning_beam.sample_spell = self
	lightning_beam.shoot()
