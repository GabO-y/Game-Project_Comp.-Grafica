extends Menu

class_name ShopMenu

@export var pos: Marker2D
@export var pop_up: Label
@export var tab_container: TabContainer

@export var weapon_upgrade_screen: WeaponUpgradesScreen

@export var select_weapon_button: Button
@export var select_upgrades_player_button: Button

func _ready() -> void:
	setup_state(MenuState.DESABLE)
	select_weapon_button.button_up.connect(
		func():
			tab_container.current_tab = 0
	)
	select_upgrades_player_button.button_up.connect(
		func():
			tab_container.current_tab = 1
	)

func enable_state(delta: float):
	if Input.is_action_just_pressed("ui_exit_menu"):
		setup_state(MenuState.DESABLE)

func desable_state(delta: float):
	
	var already_menu: bool = Globals.player.current_state == Player.PlayerState.MENU
	var in_safe_room: bool = Globals.room_manager.current_room.name == "SafeRoom"
	
	if already_menu or not in_safe_room:
		return
	
	var dist: float = pos.global_position.distance_to(Globals.player_pos())
	pop_up.visible = dist < 30.0
	if dist < 30.0:
		if Input.is_action_just_pressed("ui_menu"):
			setup_state(MenuState.ENABLE)
	
func setup_state(state: MenuState):
	match state:
		MenuState.ENABLE:
			visible = true
			get_tree().paused = true
			tab_container.tabs_position = 0
			weapon_upgrade_screen.update()
			select_weapon_button.grab_focus()
		MenuState.DESABLE:
			visible = false
			get_tree().paused = false
	current_state = state
	setup_player()
	
