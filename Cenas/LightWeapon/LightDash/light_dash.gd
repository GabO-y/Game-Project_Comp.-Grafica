extends LightWeapon

class_name LightDash

var in_dash: bool = false

var p1: Vector2 = Vector2.ZERO
var p2: Vector2 = Vector2.ZERO

var light_duration_frames: int 
var frames: int = 0

var lights_areas: Dictionary
var idle_frames: int = 5

@export var point_light_exemple: PointLight2D

var current_custom_state: CustomState = CustomState.NO_DASHING

var sprites_dash_effect: Dictionary
var last_area: Area2D
var t: float = 0.0


func _ready() -> void:
	
	attributes["damage"] = CompostAtrribute.new()
	attributes["frames_to_damage"] = CompostAtrribute.new()
	attributes["light_duration"] = CompostAtrribute.new()

	attributes["frames_to_damage"].set_attr("value", 10.0, 20.0)
	attributes["frames_to_damage"].set_attr("price", 100.0, 10.0)
	
	attributes["damage"].set_attr("value", 5.0, 1.0)
	attributes["damage"].set_attr("price", 150.0, 10.0)
	
	attributes["light_duration"].set_attr("value", 100.0, 50.0)
	attributes["light_duration"].set_attr("price", 150.0, 10.0)
	
	super._ready()
	
	await get_tree().process_frame
	Globals.room_manager.changed_room.connect(
		func(_room):
			setup_custom_state(CustomState.IDLE)
	)

	
	
	
func _physics_process(delta: float) -> void:
	print(manager)
	super._physics_process(delta)
	for sprite in sprites_dash_effect.keys():
		sprites_dash_effect[sprite] += 1
		if sprites_dash_effect[sprite] > light_duration_frames:
			manager.static_utils_node.remove_child(sprite)
			sprites_dash_effect.erase(sprite)
			continue
	for area in lights_areas.keys():
		
		if not is_instance_valid(area):
			lights_areas.erase(area)
			continue
		
		lights_areas[area]["frames"] += 1

		if lights_areas[area]["frames"] > light_duration_frames:
			lights_areas.erase(area)
			manager.static_utils_node.remove_child(area)
			continue
		
		for ene in lights_areas[area]["ene_in_light"].keys():
			lights_areas[area]["ene_in_light"][ene] += 1
			if lights_areas[area]["ene_in_light"][ene] > frames_to_damage:
				ene.take_damage(damage)
				if ene.heart <= 0:
					lights_areas[area]["ene_in_light"].erase(ene)
					continue
				lights_areas[area]["ene_in_light"][ene] = 0
				
	in_dash = Globals.player.current_state == Player.PlayerState.DASHING

	if not lights_areas.is_empty():
		sprite_shine_effect(delta)

func custom_state(delta: float):
	match current_custom_state:
		CustomState.DASHING:
			dashing_state(delta)
		CustomState.NO_DASHING:
			no_dasing_state(delta)
		CustomState.IDLE:
			frames += 1
			if frames > idle_frames:
				setup_custom_state(CustomState.NO_DASHING)
			
func dashing_state(delta: float):
	ghost_dash_effect()
	if not in_dash:
		setup_custom_state(CustomState.NO_DASHING)
	
func no_dasing_state(delta: float):
	if in_dash:
		setup_custom_state(CustomState.DASHING)
	
func setup_custom_state(state: CustomState):
	current_custom_state = state
	match state:
		CustomState.DASHING:
			p1 = Globals.player_pos()
		CustomState.NO_DASHING:
			p2 = Globals.player_pos()
			if p1 and p2:
				var area: Area2D = Area2D.new()
				area.collision_layer = Globals.layers["weapon"]
				area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"] | Globals.layers["boss"]
				var collision: CollisionShape2D = CollisionShape2D.new()
				var shape: CapsuleShape2D = CapsuleShape2D.new()
				collision.shape = shape
				area.add_child(collision)
				
				var dir: Vector2 = p1.direction_to(p2)
				var dist: float = p1.distance_to(p2)
				
				area.global_position = p1 + dir * dist * 0.5
				area.rotation = dir.rotated(deg_to_rad(90.0)).angle() 
				manager.static_utils_node.add_child(area)
			
				shape.height = dist
				
				lights_areas[area] = {
					"frames": 0,
					"ene_in_light": {},
					"sprites": []
				}
				
				area.body_entered.connect(
					func(body):
						var ene: Enemy = body.get_parent() as Enemy
						if ene and not enemies_in_light.has(ene):
							lights_areas[area]["ene_in_light"][ene] = 0
				)
				
				area.body_exited.connect(
					func(body):
						if not lights_areas.has(area):
							return
						var ene: Enemy = body.get_parent() as Enemy
						if ene:
							lights_areas[area]["ene_in_light"].erase(ene)
				)
		CustomState.IDLE:
			frames = 0
			for child in Globals.weapon_manager.static_utils_node.get_children():
				if is_instance_valid(child):
					if child is Area2D:
						child.collision_layer = 0
						child.collision_mask = 0
					Globals.weapon_manager.static_utils_node.remove_child(child)
					child.queue_free()

func update_status(name: String):
	if not attributes.has(name): return
	var attr: CompostAtrribute = attributes[name]
	match name:
		"light_duration": 
			light_duration_frames = attr.get_attr("value")
	super.update_status(name)
	
func ghost_dash_effect():
	
	if not in_dash: return
	
	var player: Player = Globals.player
	var anim: AnimatedSprite2D = player.anim
	
	var anim_name: String = anim.animation
	var frame: int = anim.frame
	var all_frames: SpriteFrames = anim.sprite_frames
	
	var texture: Texture2D = all_frames.get_frame_texture(anim_name, frame)
	var sprite: Sprite2D = Sprite2D.new()
	
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
	sprite.global_position = Globals.player_pos()
	
	manager.static_utils_node.add_child(sprite)
	sprites_dash_effect[sprite] = 0
	

func sprite_shine_effect(delta: float):
	t += delta * 1.5
	if t > 1.0:
		t = 0.0
	for s in sprites_dash_effect.keys():
		
		if not is_instance_valid(s):
			sprites_dash_effect.erase(s)
			continue
		
		var x: float = (2 * t * t) - (2 * t) + 1
		var a_color: Color = Color(1, 1, 0) * 10.0 
		a_color.a = 2.0
		var b_color: Color = Color.YELLOW * Color(1, 1, 1, 0.1)
		s.modulate = a_color + (b_color - a_color) * x

enum CustomState {DASHING, NO_DASHING, IDLE}
	
