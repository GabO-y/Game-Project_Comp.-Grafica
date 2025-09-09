extends CharacterBody2D

var speed = 200

func _physics_process(delta: float) -> void:
			
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X) 
	input_vector.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1

	if input_vector.length() < 0.2:
		input_vector = Vector2.ZERO
	else:
		input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
	
	
