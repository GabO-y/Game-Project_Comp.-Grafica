extends Bullet

class_name FairyPowerUpBullet

func _ready() -> void:
	collision_area.collision_layer = Globals.layers["weapon"] | Globals.layers["player"]
	collision_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]

func _ene_enter_light(body: Node2D) -> void:
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		ene.take_damage(1)
		queue_free()
