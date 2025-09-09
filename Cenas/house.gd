extends Node2D

@onready var lantern := $Lantern
@onready var test := $ColissionTest/Area2D as Area2D
@onready var player := $Player/CharacterBody2D

func _ready() -> void:

	var lanternArea = lantern.get_node("Light") as Area2D
	test.area_entered.connect(lanternArea._on_light_area)

func _process(delta: float) -> void:
	lantern.global_position = player.global_position

	
