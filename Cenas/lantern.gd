extends Node2D

@export var rotation_speed := 5.0

func _process(delta):
	# Pega eixo do analógico direito (geralmente 2 = X, 3 = Y no controle padrão)
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	var dir = Vector2(x_axis, y_axis)

	if dir.length() > 0.2: # deadzone
		rotation = dir.angle()
