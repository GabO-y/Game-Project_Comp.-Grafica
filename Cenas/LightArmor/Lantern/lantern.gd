extends LightArmor

class_name Lantern

@export var rotation_speed := 5.0

var ene_on_light = {}
var mouse_move = false

func _ready() -> void:	
	damage = 2
	energie = 10000
	super._ready()
	area.body_entered.connect(_ene_join_light)
	area.body_exited.connect(_ene_exit_light)

func _process(delta):
	
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	var dir = Vector2(x_axis, y_axis)

	if dir.length() > 0.2: 
		rotation = dir.angle() - PI/2
	elif mouse_move:
		var mouse_pos = get_global_mouse_position()
		dir = (mouse_pos - global_position).normalized()
		rotation = dir.angle() - PI/2 
		
	damage_logig(delta)
	super._process(delta)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_move = true
	else:
		mouse_move = false
		

func damage_logig(delta: float):
	
	for key in ene_on_light:
		if ene_on_light[key] >= 1.5:
			key.take_damage(damage)	
			ene_on_light[key] = 0		
		ene_on_light[key] += delta		

func _ene_join_light(body: Node2D) -> void:
	var ene = body.get_parent()
	if ene is not Enemy: return
	ene_on_light[ene] = 0.0

func _ene_exit_light(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if ene == null: return
	ene_on_light.erase(ene)
