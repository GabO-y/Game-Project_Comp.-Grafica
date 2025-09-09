extends Node2D

@onready var enimie := $EnemiePattener/CharacterBody2D 
@onready var playerArmor := $Player/CharacterBody2D/LightArmor

func _ready() -> void:
	playerArmor.hit.connect(enimie._on_light_area)
	
