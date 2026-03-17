extends Menu

class_name GodMenu

@export var main_container: MarginContainer
@export var check_box_button_mode: VBoxContainer
@export var rooms_node: VBoxContainer

func setup_state(state: MenuState):
	if not Globals.house.can_use_god_menu:
		state = MenuState.DESABLE
	match state:
		MenuState.ENABLE:
			main_container.visible = true
		MenuState.DESABLE:
			main_container.visible = false
	current_state = state
	setup_player()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_god_menu"):
		if current_state == MenuState.ENABLE:
			setup_state(MenuState.DESABLE)
			layer = 10
		else:
			setup_state(MenuState.ENABLE)

func setup():
	setup_god_vars()
	setup_teleport_room()

func setup_teleport_room(): pass
	

func setup_god_vars():
	for key in Globals.god_vars.keys():
		var v: bool = Globals.god_vars[key]
		var b: CheckButton = CheckButton.new()
		check_box_button_mode.add_child(b)
		b.text = key
		b.alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.button_pressed = v
		b.button_up.connect(
			func():
				Globals.god_vars[key] = not Globals.god_vars[key]
				b.button_pressed = Globals.god_vars[key]
		)
