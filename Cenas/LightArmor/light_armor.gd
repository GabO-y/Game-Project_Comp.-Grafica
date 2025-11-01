extends Node2D

class_name LightArmor

@export var damage: int = 0
@export var energie = 0

@export var is_active = true
@export var area: Area2D

var enemies_on_light: Dictionary[Enemy, float] = {}
var mouse_move = false
var time_to_damage: float = 1.5

func _ready() -> void:
	area.collision_layer = Globals.layers["armor"] | Globals.layers["player"]
	area.collision_mask = Globals.layers["enemy"] | Globals.layers["boss"]
	
	area.body_entered.connect(_ene_on_light_area)
	area.body_exited.connect(_ene_exit_light_area)

func _process(delta: float) -> void:
	
	if Globals.player.is_in_menu: return
	
	damager_ene(delta)
	
	if Input.is_action_just_pressed("ui_toggle_armor"):
		toggle_activate()

func toggle_activate():
	
	is_active = !is_active
	area.visible = is_active
		
	if is_active:
		area.collision_mask = Globals.layers["ghost"] | Globals.layers["enemy"] | Globals.layers["boss"]
		area.collision_layer = Globals.layers["player"] | Globals.layers["armor"] | Globals.layers["wall_current_room"]
	else:
		area.collision_layer = 0
		area.collision_mask = 0


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_move = true
	else:
		mouse_move = false
	
func damager_ene(delta: float):
	for ene in enemies_on_light.keys():
		if enemies_on_light[ene] >= time_to_damage:
			ene.take_damage(damage)
			enemies_on_light[ene] = 0.0
			continue
		enemies_on_light[ene] += delta
	
func _ene_on_light_area(ene_body):
	var ene = ene_body.get_parent() as Enemy
	if !ene: return
	enemies_on_light[ene] = 0.0
	
func _ene_exit_light_area(ene_body):
	var ene = ene_body.get_parent() as Enemy
	if !ene: return
	for key in enemies_on_light.keys():
		if ene == key:
			enemies_on_light.erase(key)
			break
			
	

	
	

	
