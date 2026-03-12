extends Sprite2D

func _ready() -> void:
	await get_tree().process_frame
	update_background_size()
	get_window().size_changed.connect(update_background_size)
	
func update_background_size():
	var cube = GradientTexture2D.new()
	var s_size: Vector2 = get_viewport_rect().size
	
	cube.width = s_size.x
	cube.height = s_size.y

	var color_target: Color = Color( 
		9.0 / 255.0, 
		5.0 / 255.0, 
		31.0 / 255.0)
		
	var color: Color = color_target / Color(Globals.backlayer_filter.color)
	modulate = color
	texture = cube
		
