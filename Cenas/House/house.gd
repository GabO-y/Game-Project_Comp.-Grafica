extends Node2D

@onready var enimie := $EnemiePattener
@onready var player := $Player/CharacterBody2D
@onready var fantasm := $Fantasm/CharacterBody2D

var activateArmor = true
var armor: LightArmor

func _ready() -> void:
	
	armor = player.armor
	print(armor)
	armor.set_activate(false);
		
func _process(delta: float) -> void:
	
	#var n = get_tree().get_nodes_in_group("Armor")
	#print("Aqui")
	#for i in n:
		#print(n)
	#print("fim")
	
	toggle_activate_armor()
		
func toggle_activate_armor() -> void:
	if Input.is_action_just_pressed("ui_toggle_armor"):
		armor.set_activate(activateArmor)
		activateArmor = !activateArmor
		
	
