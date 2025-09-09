extends Node2D

@onready var enimie := $EnemiePattener/CharacterBody2D 
@onready var player := $Player/CharacterBody2D

var activateArmor = true
var armor: LightArmor

func _ready() -> void:
	
	armor = player.armor
	armor.set_activate(false)
	player.hit.connect(enimie._on_light_area)
	
func _process(delta: float) -> void:
	toggle_activate_armor()
	

func toggle_activate_armor() -> void:
	if Input.is_action_just_pressed("ui_toggle_armor"):
		armor.set_activate(activateArmor)
		activateArmor = !activateArmor
		
	
