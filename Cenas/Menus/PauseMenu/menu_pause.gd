extends Menu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_state = MenuState.DESABLE
	await get_tree().process_frame
	set_active(false)
	
func _process(delta: float) -> void:
	if Globals.player.current_state == Player.PlayerState.ANIMATION: return
	super._process(delta)
			
			
func setup_state(state: MenuState):
	match state:
		MenuState.ENABLE:
			visible = true
			get_tree().paused = true
			#last_player_state = Globals.player.current_state
		MenuState.DESABLE:
			visible = false
			get_tree().paused = false

	current_state = state
	setup_player()
			
func enable_state(delta: float):
	if Input.is_action_just_pressed("ui_exit_menu"):
		setup_state(MenuState.DESABLE)
		
func desable_state(delta: float):
	if Globals.player.current_state != Player.PlayerState.MENU: 
		if Input.is_action_just_pressed("ui_exit_menu"):
			setup_state(MenuState.ENABLE)
			
func show_menu():
	set_active(true)
	
func hide_menu():
	set_active(false)
	
func _on_button_pressed() -> void:
	#hide_menu()
	setup_state(MenuState.DESABLE)

func _on_exit_button_down() -> void:
	Globals.house.reset()
	Globals.house.inital_menu.setup_state(Menu.MenuState.ENABLE)
	#Globals.house.inital_menu.start()
	

func _on_finish_round_pressed() -> void:
	setup_state(MenuState.DESABLE)
	Globals.player.hearts = 0
	Globals.player.die()
