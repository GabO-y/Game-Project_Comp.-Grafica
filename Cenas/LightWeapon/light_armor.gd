extends Node2D

class_name LightWeapon

@export var light_area: Area2D
@export var current_state: LightWeaponState

var manager: WeaponManager

var enemies_in_light: Dictionary

var is_use_mouse: bool = true
var price: float = 0.0

var can_toggle: bool = true

var last_dir: Vector2 = Vector2.LEFT


# idea:
#	cada arma conterá um atributo, nesse dicionario
#	vc guarda o nome, e uma CompostAttribute
#	que pode guardar o valor e o preço pelo level do atributo
#exemplo:
#	atributo: damage
#	sub_atributo: value { min: 10, max: 50, max_level: 10 }
#	sub_atributo: price { min: 50, max: 200, max_level: 5 }
#	> dessa forma, podemos, no atributo de damage, pegar seu valor
#	> e seu preço

var attributes: Dictionary = {} # { name : CompostAttribute }

var damage: int 
var frames_to_damage: int 

func _ready() -> void:
	light_area.collision_layer = Globals.layers["player"] | Globals.layers["weapon"]
	light_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
	light_area.body_entered.connect(ene_enter_light)
	light_area.body_exited.connect(ene_exit_light)
	await get_tree().process_frame
	for key in attributes.keys():
		update_status(key)
	
func _physics_process(delta: float) -> void:
	match current_state:
		LightWeaponState.ENABLE:
			enable_state(delta)
		LightWeaponState.DESABLE:
			desable_state(delta)
		LightWeaponState.CUSTOM:
			custom_state(delta)

func enable_state(delta: float):
	for ene in enemies_in_light.keys():
		enemies_in_light[ene] += 1
		if enemies_in_light[ene] > frames_to_damage:
			var d: int = int(damage)
			(ene as Enemy).take_damage(d)
			enemies_in_light[ene] = 0
	if Input.is_action_just_pressed("ui_toggle_armor"):
		setup_state(LightWeaponState.DESABLE)

func desable_state(delta: float):
	if not can_toggle: return
	if Input.is_action_just_pressed("ui_toggle_armor"):
		setup_state(LightWeaponState.ENABLE)
	
func setup_state(state: LightWeaponState):
	match state:
		LightWeaponState.ENABLE:
			visible = true
			light_area.collision_layer = Globals.layers["player"] | Globals.layers["weapon"]
			light_area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
		LightWeaponState.DESABLE:
			visible = false
			light_area.collision_layer = 0
			light_area.collision_mask = 0
			enemies_in_light = {}
	current_state = state
	
func ene_enter_light(body: Node2D):
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		if ene.heart <= 0:
			return
		enemies_in_light[ene] = 0
		
func ene_exit_light(body: Node2D):
	var ene: Enemy = body.get_parent() as Enemy
	if ene:
		enemies_in_light.erase(ene)

func _input(event: InputEvent) -> void:
	is_use_mouse = (event is InputEventMouseButton) or (event is  InputEventMouseMotion)

func update_status(name: String):
	if not attributes.has(name): return
	var attr: CompostAtrribute = attributes[name]
	match name:
		"damage":
			damage = attr.get_attr("value")
		"frames_to_damage":
			frames_to_damage = attr.get_attr("value")
		"distance":
			scale = attr.get_attr("value")

func get_dir() -> Vector2:
	var dir: Vector2 
	if is_use_mouse:
		dir = global_position.direction_to(get_global_mouse_position())
	else:
		dir.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		dir.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if dir == Vector2.ZERO:
		dir = last_dir
	else:
		last_dir = dir
	return dir

func custom_state(delta: float):
	pass


enum LightWeaponState {ENABLE, DESABLE, CUSTOM}
