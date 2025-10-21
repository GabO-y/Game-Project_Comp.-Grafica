extends Room

@export var segs_node: Node2D
@export var boss: MegaGhost

var time_of_run_ghosts = 12;

var is_attack_running_fantasm = false

var COLL_LAYER = 1 << 7
var ENE_LAYER = 1 << 3

var fantasm_on_attack = []
var is_last_update_bar = false
var time_can_go = 3

func _ready():
	setup()
	
func _process(delta: float) -> void:
	if is_last_update_bar:
		$DamageBar.value -= 0.4
		if $DamageBar.value <= 0:
			is_last_update_bar = false
	
func _on_inside_area_body_entered(body: Node2D) -> void:
	refrash_setup()
	boss.refrash_setup()
	
func refrash_setup():
	is_attack_running_fantasm = false
	time_can_go = 3
	fantasm_on_attack.clear()
	
func _last_update_damage_bar(ene: Enemy) -> void:
	$DamageBar/LifeBar.value = 0
	await get_tree().create_timer(2).timeout
	is_last_update_bar = true
	
func switch_process(mode: bool):
	boss.is_active = mode
	boss.set_process(mode)
	boss.set_physics_process(mode)
	super.switch_process(mode)
	
