extends Part

class_name MinPart

var already_vanish = false

func split():
	
	if is_min_min: return
	
	var parts = super.split()
	parts[0].is_min_min = true
	parts[1].is_min_min = true
		
	await Globals.time(10)
	
	parts[0].locals = locals
	parts[1].locals = locals
	
	parts[0].toward_center = true
	parts[1].toward_center = true
	
	parts[0].body.collision_layer = 1
	parts[1].body.collision_layer = 1
	
	parts[0].body.collision_mask = 0
	parts[1].body.collision_mask = 0
	
	speed_special_attack = 200
	


func _process(delta: float) -> void:
	
	if toward_center:
				
		dir_special_attack = body.global_position.direction_to(center_pos).normalized()
		
		var dist = body.global_position.distance_to(center_pos)

		if dist <= 1500 and modulate.a > 0:
		
			var t = clamp(1 - (dist / 100), 0, 1)
			var alpha = pow(t, 10)
			modulate.a -= alpha
	
		if modulate.a <= 0 and dist < 30 and not already_vanish:
			locals.goint_to_center.emit()
			already_vanish = true
	
		body.velocity = dir_special_attack * 200
		body.move_and_slide()
		
	else:
		super._process(delta)
