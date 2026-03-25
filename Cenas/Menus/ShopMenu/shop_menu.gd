extends Menu

class_name ShopMenu

@export var pos: Marker2D
@export var pop_up: Label
@export var tab_container: TabContainer

@export var weapon_upgrade_screen: WeaponUpgradesScreen
@export var player_upgrade_screen: PlayerUpgradeScreen

@export var select_weapon_button: Button
@export var select_upgrades_player_button: Button

@export var label_coins: Label

var scroll_focus: ScrollContainer
var scroll_speed: float = 30.0

func _ready() -> void:
	aux_var["original_pos_label_coins"] = label_coins.global_position 
	setup_state(MenuState.DESABLE)
	select_weapon_button.button_up.connect(
		func():
			tab_container.current_tab = 0
			weapon_upgrade_screen.update()
	)
	select_upgrades_player_button.button_up.connect(
		func():
			tab_container.current_tab = 1
			player_upgrade_screen.update()
	)


func enable_state(delta: float):
	if Input.is_action_just_pressed("ui_next"):
		select_upgrades_player_button.button_up.emit()
	if Input.is_action_just_pressed("ui_previus"):
		select_weapon_button.button_up.emit()
	if Input.is_action_just_pressed("ui_toggle_menu"):
		setup_state(MenuState.DESABLE)
	if aux_var["inssu_effect"]:
		insufficiente_coin_state()
	if scroll_focus:
		var y: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		scroll_focus.scroll_vertical += y * scroll_speed

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
			aux_var["play"] = false
			insufficiente_coin_effect()
			aux_var["inssu_effect"] = false
			label_coins.modulate = Color.WHITE
		MenuState.DESABLE:
			label_coins.global_position = aux_var["original_pos_label_coins"] 
			visible = false
			get_tree().paused = false
	current_state = state
	setup_player()
	
func insufficiente_coin_state():
	label_coins.global_position = aux_var["original_pos_label_coins"] 
	if aux_var["effect_frames"] > aux_var["effect_frames_limit"]:
		aux_var["inssu_effect"] = false
		aux_var["effect_frames"] = 0
		label_coins.modulate = Color(1, 1, 1)
	else:
		if aux_var["effect_frames"] % 7 == 0:
			var dir: Vector2 = Globals.get_random_dir()
			label_coins.global_position += dir * 7.0
		aux_var["effect_frames"] += 1
		label_coins.modulate = Color.RED
		
func insufficiente_coin_effect():
	aux_var["inssu_effect"] = true
	aux_var["effect_frames"] = 0
	aux_var["effect_frames_limit"] = 30
	label_coins.text = str(Globals.player.coins)
	if aux_var["play"]:
		Globals.audio_manager.play("inssuficient_coin", "Items")
	aux_var["play"] = true

func update_coin():
	label_coins.text = str(Globals.player.coins)
	
