extends CanvasLayer

class_name Menu

@export var manager: MenuManager
@export var is_active: bool = false
@export var focus_button: Button
@export var need_focus: bool = true

var aux_var: Dictionary = {}

enum MenuState {ENABLE, DESABLE}

var current_state: MenuState = MenuState.DESABLE

var last_player_state: int

func set_active(mode: bool, principal: bool = true):
	
	if Globals.player:
		Globals.player.hud_node.visible = not mode
		
	if mode and need_focus:	
		focus_button.grab_focus()
		
	get_tree().paused = mode
	
	#set_process_unhandled_input(mode)
	#set_process_input(mode)
	#set_process_unhandled_key_input(mode)
	
	#is_active = mode
	#visible = mode

	if not principal: return

	#if mode:
		#manager.current_menu = self
		#manager.is_in_menu = true
		#for menu in manager.menus:
			#if menu != self:
				#menu.set_active(false, false)
	#else:
		#if manager.current_menu == self:
			#manager.current_menu = null
			#manager.is_in_menu = false
		#for menu in manager.menus:
			#if menu is FinishMenu: continue
			#menu.set_process(true)
			#
			
func _process(delta: float) -> void:
	match current_state:
		MenuState.ENABLE:
			enable_state(delta)
		MenuState.DESABLE:
			desable_state(delta)
			
func enable_state(delta: float):
	pass
	
func desable_state(delta: float):
	pass
			
func setup_player():
	var player: Player = Globals.player
	if not player: return
	match current_state:
		MenuState.ENABLE:
			last_player_state = Globals.player.current_state
			player.current_state = Globals.player.PlayerState.MENU
		MenuState.DESABLE:
			if last_player_state:
				player.current_state = last_player_state
			else:
				player.current_state = Player.PlayerState.MOVING
			

func reset():
	set_active(false)
		
func setup_state(state: MenuState):
	pass
