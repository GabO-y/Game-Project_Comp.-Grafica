extends Menu

@export var resume_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_state = MenuState.DESABLE
	await get_tree().process_frame
	
func _process(delta: float) -> void:
	if Globals.player.current_state == Player.PlayerState.ANIMATION: return
	super._process(delta)
			
			
func setup_state(state: MenuState):
	match state:
		MenuState.ENABLE:
			visible = true
			get_tree().paused = true
			resume_button.grab_focus()
		MenuState.DESABLE:
			visible = false
			get_tree().paused = false

	current_state = state
	setup_player()
			
func enable_state(delta: float):
	if Input.is_action_just_pressed("ui_toggle_menu"):
		setup_state(MenuState.DESABLE)
		
func desable_state(delta: float):
	if Globals.player.current_state != Player.PlayerState.MENU: 
		if Input.is_action_just_pressed("ui_pause_menu"):
			setup_state(MenuState.ENABLE)
			
func _on_button_pressed() -> void:
	#hide_menu()
	setup_state(MenuState.DESABLE)

func _on_exit_button_down() -> void:
	Globals.house.reset()
	Globals.house.inital_menu.setup_state(Menu.MenuState.ENABLE)
	

func _on_finish_round_pressed() -> void:
	setup_state(MenuState.DESABLE)
	Globals.player.hearts = 0
	Globals.player.die()
