extends Character
class_name Player


@export var armor: LightArmor
var armorEnergie

func _ready() -> void:
	armor = preload("res://Cenas/LightArmor/Lantern/lantern.tscn").instantiate()
	add_child(armor)
	
