extends Character

@export var armor: LightArmor
var armorEnergie

func _ready() -> void:
	armor = preload("res://Cenas/LightArmor/Lighter/Lighter.tscn").instantiate()
	add_child(armor)
	
signal hit(body: Enemie)
