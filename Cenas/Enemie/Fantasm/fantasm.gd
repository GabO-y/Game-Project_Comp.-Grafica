extends Enemie

class_name Fantasm

@onready var anim := $CharacterBody2D/AnimatedSprite2D

func _ready() -> void:
	
	damage = 5
	speed = 100
	life = 5
	size_chase_area = 100
	
	super._ready()
	
func _process(_delta: float) -> void:
	animation_logic()
	
func animation_logic():
	var play := ""
	
	if dir == Vector2.ZERO: return
	
	if dir.x > 0:
		play = "right"
	else:
		play = "left"
	
	if dir.y < 0:
		play += "_back"
		
	print(play)
		
	anim.play(play)
		
	
	
	
	
	
