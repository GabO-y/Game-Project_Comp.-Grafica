extends Split

@export var min_split: Split

var is_splited = false

func _ready() -> void:
	min_split.visible = false	

func split_when_crash():
	
#	Esse é o split do mid (que gera dois pequenos)
		
#	essa é uma variavel exportada

	min_split.is_active = true	
	var min_split_2 = min_split.duplicate()
	
	add_child(min_split_2)
	
	ene_in_crash_attack.append(min_split)
	ene_in_crash_attack.append(min_split_2)
	
		
	for ene in ene_in_crash_attack:
		
		ene.show()
			
		ene.dir_special_attack = dir_special_attack
		ene.speed_special_attack = speed_special_attack
		ene.last_wall_collide = last_wall_collide
		
		ene.body.collision_mask = 1 << 2
		ene.body.collision_layer = 1 << 2
		
		ene.set_collision_layer_ray(3)
								
		match last_wall_collide:
			"down", "up":
				min_split.body.global_position = vertical_point_1.global_position
				min_split_2.body.global_position = vertical_point_2.global_position 
			"left", "right":
				min_split.body.global_position = horizontal_point_1.global_position
				min_split_2.body.global_position = horizontal_point_2.global_position 	

	
	min_split_2.dir_special_attack = -dir_special_attack
		
	body.hide()
	body.collision_layer = 0
	body.collision_mask = 0
	
	set_collision_layer_ray(0)

func move_all():
	for ene in ene_in_crash_attack:
		ene = ene as MinSplit
		ene.move_crash_wall()
		
func _big_split(ene_in_crash_attack: Array[Enemy]) -> void:
	self.ene_in_crash_attack = ene_in_crash_attack
