class_name LightningBeam
extends RayCast2D

@export_range(1, 10, 1) var flashes := 3
@export_range(0.0, 3.0) var flash_time := 0.1
@export var damage := 5.0
@export var lightning_jolt: PackedScene = preload("res://vfxs/lightning_beam/lightning_jolt.tscn")

var sample_spell: ThunderRiffSpell
var target: Enemy
var additional_targets: Array[Enemy] = []
var target_point: Vector2:
	get(): return target.global_position

func shoot() -> void:
	target.get_hit(damage)
	
	for flash in range(flashes):
		var jolt = lightning_jolt.instantiate()
		jolt.start = global_position
		jolt.end = target_point
		jolt.duration = flash_time
		add_child(jolt)
		
		if additional_targets != null and additional_targets.size() > 0:
			var previous_point = target_point
			
			for _i in range(additional_targets.size()):
				var enemy: Enemy = additional_targets[_i]
				jolt = lightning_jolt.instantiate()
				jolt.start = previous_point
				jolt.end = enemy.global_position
				add_child(jolt)
				enemy.get_hit(damage)
				previous_point = jolt.end
			
			additional_targets = []
		
		await get_tree().create_timer(flash_time).timeout
