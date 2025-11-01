extends Item

class_name Key

@export var particles_node: CPUParticles2D

var door1: Door
var door2: Door


var is_in_open_door: bool = false

var is_going_to_door: bool = false
var is_particles_active: bool = false

var is_getting_key: bool = false

func _ready() -> void:
	super._ready()
	particles_node.amount = 0

func _process(delta: float) -> void:
	
	if is_in_open_door:
		
		if is_getting_key:
			if Input.is_anything_pressed():
				finish_get_key()
			return
			
		if is_particles_active: 
			if Input.is_anything_pressed():
				finish_particles()
			return
				
		
	super._process(delta)

func start_chase_player():
	super.start_chase_player()
	curve.set_t(0.007)
	
func use():
	door1.is_locked = false
	door2.is_locked = false
	Globals.room_manager.current_room._clear_effects()
	queue_free()
	
func finish_get_key():
		
	is_getting_key = false
	
	set_go_to(door1.position)
	use_when_arrieve.connect(start_particles)

func start_particles():
	
	var tween = create_tween()
	particles_node.visible = true

	tween.tween_property(particles_node, "amount", 50, 0.001)
	
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 2.0)
	
	is_getting_key = false
		
	await tween.finished
	is_particles_active = true
	
	
func finish_particles():
	
	Globals.player.is_getting_key = false
	Globals.player.set_process(true)
	Globals.player.set_physics_process(true)
	
	Globals.house.desable_camera()
	use()		
	
signal use_when_arrieve
	
