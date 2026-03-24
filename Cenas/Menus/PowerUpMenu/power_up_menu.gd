extends Menu

class_name PowerUpMenu

@export var power_ups_node: Control
@export var power_name: Label
@export var power_description: RichTextLabel

var select_frames: int = 50

var power_ups: Array[PowerUp]

func _ready() -> void:
	get_viewport().size_changed.connect(
		func():
			if current_state == MenuState.ENABLE:
				set_power_ups()
	)

func setup_state(state: MenuState):
	current_state = state
	match state:
		MenuState.ENABLE:
			visible = true
			set_power_ups()
		MenuState.DESABLE:
			visible = false
	setup_player()

			
func set_power_ups():
	
	var s_size: Vector2 = get_viewport().size
	
	var x: float = s_size.x * 100.0 / 1920.0
	var y: float = s_size.y * 100.0 / 1080.0 
	var width: float = 400.0 * (x / 100.0)
	var heigth: float = 400.0 * (y / 100.0)
	
	for child in power_ups_node.get_children():
		power_ups_node.remove_child(child)
		
	var is_first: bool = true
		
	for up in power_ups:
		var item: PowerUpMenuItem = load("res://Cenas/Menus/PowerUpMenu/PowerUpMenuItem/PowerUpMenuItem.tscn").instantiate()	
		power_ups_node.add_child(item)
		var texture: GradientTexture2D = item.texture
		
		if width != heigth:
			var max = max(width, heigth)
			width = max
			heigth = max
		
		texture.width = width
		texture.height = heigth
		
		item.texture = texture
		item.menu = self
		item.power_up = up
		
		if not up.icon_path.is_empty():
			item.button.icon = load(up.icon_path)
		

		item.button.button_down.connect(
			func():
				item.button.grab_focus()
				power_name.text = up.power_up_name + "\n"
				power_description.text = up.power_up_description + "\n"
		)
		
		if is_first:
			item.button.button_down.emit()
			item.button.button_up.emit()
			is_first = false
		
		
