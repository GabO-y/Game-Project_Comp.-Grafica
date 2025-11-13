extends Menu

class_name DieMenu

@export var anim: AnimationPlayer

@export var label_ene_defalted: Label
@export var label_coin_already: Label
@export var label_coin_conquisted: Label

var is_in_die_menu: bool = false
var part: int = 0
var can_skip: bool = false

var tween_die: Tween

var to_tween_skip: ToTweenSkip = ToTweenSkip.new()


func _ready() -> void:
	
	set_visible_labels(false)
	
	await get_tree().process_frame
	Globals.player.die.connect(start)

func start():
	
	is_in_die_menu = true
	part = 1
	
	set_visible_labels(true, 1)
	start_player_die_anim()
	anim.play("Part1")
	
	await Globals.time(1.5)
	can_skip = true	
		
	
func set_visible_labels(mode: bool, type: int = 0):
	
	for labels in anim.get_children():
		
		if type == 0 or labels.name.contains(str(type)):
			labels.visible = mode
	
func reset():
	super.reset()
	set_visible_labels(false)


func skip_logic():
	
	if can_skip:
		match part:
			1: skip_1()
			2: pass
			
	part += 1
	
	if part > 2:
		part = 2
		
func skip_1():
	
	anim.seek(anim.current_animation.length() + 1000, true)
	
	tween_die.stop()
	
	Globals.player.scale = to_tween_skip.target_scala 
	Globals.player.body.global_position = to_tween_skip.target_position
	Globals.player.anim.set_frame_and_progress(100, 100)
	
	start_part_2()

func start_player_die_anim():
	
	get_tree().paused = true
	await get_tree().process_frame
	
	Globals.player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	Globals.player.is_dead = true  
	
	Globals.player.set_process(false)
	Globals.player.set_physics_process(false)
	
	Globals.player.armor.set_process(false)
	Globals.player.armor.set_physics_process(false)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	if Globals.player.armor.is_active:
		Globals.player.armor.toggle_activate() 
	
	var center: Vector2 = Globals.room_manager.current_room.camera.global_position
	var scala: Vector2 = Vector2(4.0, 4.0)
	
	var duration: float = 7.0
	to_tween_skip.target_position = center
	to_tween_skip.target_scala = scala
	
	print("hakdjf 11: ", to_tween_skip.target_position)
	
	tween.tween_property(Globals.player, "scale", scala, duration)
	tween.tween_property(Globals.player.body, "global_position", center, duration)
	
	Globals.player.anim.play("die")
	
	tween.finished.connect(
		func():
			start_part_2()
	)
	
	tween_die = tween
	
signal finished_die_anim
	
func start_part_2():
	
	anim.play("Part2")
	print("parte 2")
	
	set_visible_labels(true, 2)
	
	label_coin_already.text = str(int(Globals.player.coins - Globals.conquited_coins), " + ")
	
	var tween = create_tween()
	
	tween.set_parallel()
	
	tween.tween_method(update_ene_label, 0.0, 1.0, 5.0)
	tween.tween_method(update_conquited_coins, 0.0, 1.0, 5.0)
	
	tween.finished.connect(
		func():
			finished.emit()
	)
	

func update_ene_label(t: float):
	label_ene_defalted.text = str( int(Globals.enemies_defalted * t) )
	
func update_conquited_coins(t: float):
	label_coin_conquisted.text = str( int(Globals.conquited_coins * t) )
	
class ToTweenSkip:
	var target_position: Vector2
	var target_scala: Vector2
	
signal finished

	
