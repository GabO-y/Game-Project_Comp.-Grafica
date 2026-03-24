extends CanvasLayer

class_name Menu

@export var manager: MenuManager
@export var is_active: bool = false
@export var focus_button: Button
@export var need_focus: bool = true

var aux_var: Dictionary = {}

enum MenuState {ENABLE, DESABLE}

@export var current_state: MenuState = MenuState.DESABLE

var last_player_state: int
			
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
			get_tree().paused = true
		MenuState.DESABLE:
			if last_player_state:
				player.current_state = last_player_state
			else:
				player.current_state = Player.PlayerState.MOVING
			get_tree().paused = false

			
func reset():
	setup_state(MenuState.DESABLE)
			
func setup_state(state: MenuState):
	pass
