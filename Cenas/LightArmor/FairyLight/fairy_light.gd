extends LightArmor

@export var aim_sprite: Sprite2D
@export var bullet: Node2D

var can_shot = true
var bullets_moving: Array[Dictionary]

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_toggle_armor"):
		toggle_activate()
		

	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	
	rotation = dir.angle()
	
	if (
		Input.is_action_just_pressed("ui_shot")
		and 
		is_active and can_shot
	):
		shot(dir.angle())
		
	for entry in bullets_moving:
		var bull = entry["bull"] as Area2D
		var dir_bull = entry["dir"] as Vector2
		bull.position += dir_bull * 2
		print(bull.global_position)

	
func toggle_activate():
	
	is_active = !is_active
	aim_sprite.visible = is_active
	
	print(is_active)
	
func shot(angle):
	var bullet_copy = bullet.duplicate()
	bullets_moving.append({"bull": bullet_copy, "dir" : Vector2.from_angle(angle)})
	
	
	
