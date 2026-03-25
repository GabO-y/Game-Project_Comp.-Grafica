extends Enemy
class_name Boss

# quarto que o boss se encontra
@export var room: BossRoom
@export var health_bar: ProgressBar
@export var damage_bar: ProgressBar

var wating_drop_health: bool = false
var time_to_drop_health: float = 1.0
var timer_to_drop_health: float = 0.0

var is_to_update_bar: bool = false

func _ready() -> void:
	super._ready()
	update_progress_bars()
	get_window().size_changed.connect(update_progress_bars)
	for i in [health_bar, damage_bar]:
		i.max_value = heart
		i.value = heart
	
	
	
func _process(delta: float) -> void:
	if wating_drop_health and timer_to_drop_health > time_to_drop_health:
		is_to_update_bar = true
		wating_drop_health = false
	if is_to_update_bar:
		if damage_bar.value > health_bar.value:
			damage_bar.value -= delta * 2
		else:
			is_to_update_bar = false
	timer_to_drop_health += delta 

func setup():
	pass
	
func reset():
	pass
	
func take_damage(damage):
	super.take_damage(damage)
	
	health_bar.value = heart
	
	is_to_update_bar = false
	wating_drop_health = true
	timer_to_drop_health = 0.0
	
	is_damaged.emit()
	
func update_progress_bars():
	var s_size: Vector2 = get_viewport_rect().size
	var delta_x: float = s_size.x * 0.1
	var delta_y: float = s_size.y * 0.9
	var pos: Vector2 = Vector2(delta_x, delta_y)
	health_bar.global_position = pos
	damage_bar.global_position = pos
	
	health_bar.size.x = delta_x * 8
	damage_bar.size.x = delta_x * 8
	
	health_bar.size.y = s_size.y * 0.05
	damage_bar.size.y = s_size.y * 0.05
	
	
signal is_damaged
