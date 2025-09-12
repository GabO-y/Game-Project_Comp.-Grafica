extends LightArmor

class_name Lantern

@export var rotation_speed := 5.0

func _ready() -> void:
	energie = 100

func _process(delta):
	
	energie_logic()
		
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	var dir = Vector2(x_axis, y_axis)

	if dir.length() > 0.2: # deadzone
		rotation = dir.angle()
		
	#var mouse_pos = get_global_mouse_position()
	#dir = (mouse_pos - global_position).normalized()
	#rotation = dir.angle()
