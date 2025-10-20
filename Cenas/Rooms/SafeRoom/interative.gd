extends Node2D

@export var area: Area2D
@export var chest_ui: ChestUi

var menu_open = false
var is_visible_pop_up = false

func _process(delta: float) -> void:
	
	var dist = area.global_position.distance_to(Globals.player_pos)
	
	if not menu_open and dist  < 20:
		chest_ui.show_popup()
		is_visible_pop_up = true
		
	if is_visible_pop_up and dist > 20:
		chest_ui.hide_pop_up()
		is_visible_pop_up = false
		
	if is_visible_pop_up and Input.is_action_just_pressed("ui_menu"):
		chest_ui.show_menu()
		
		
