extends Control

class_name ChestUi

@export var popup: PanelContainer
@export var menu: PanelContainer
@export var area: Area2D

var is_visible_pop_up = false

func _ready() -> void:
	hide_pop_up()
	hide_menu()
	
func _process(delta: float) -> void:
	
	var dist = area.global_position.distance_to(Globals.player_pos)
	
	if dist < 30 and not is_visible_pop_up:
		show_popup()
		is_visible_pop_up = true
		
	if dist > 30 and is_visible_pop_up:
		hide_pop_up()
		is_visible_pop_up = false
		
	if is_visible_pop_up and Input.is_action_just_pressed("ui_menu"):
		hide_pop_up()
		show_menu()
		Globals.player.is_in_menu = true
		
	if Globals.player.is_in_menu and Input.is_action_just_pressed("ui_exit_menu"):
		hide_menu()
		Globals.player.is_in_menu = false
		

func show_popup():
	set_visible_pop_up(true)
	
func hide_pop_up():
	set_visible_pop_up(false)
	
func show_menu():
	set_visible_menu(true)
	menu.process_mode = Node.PROCESS_MODE_DISABLED

func hide_menu():
	set_visible_menu(false)
	menu.process_mode = Node.PROCESS_MODE_INHERIT
	
func set_visible_pop_up(mode: bool):
	popup.visible = mode
	
func set_visible_menu(mode: bool):
	if Globals.player:
		Globals.player.is_in_menu = mode
	menu.visible = mode

func _on_button_pressed() -> void:
	print("a")
