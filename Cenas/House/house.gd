extends Node2D

@onready var player := $Player
@onready var enemies: Array[Enemie]

@onready var room_manager := $RoomManager

var activateArmor = true
var armor: LightArmor
var infosModeActivate = false
var spawns: Array[Spawn] = []

func _ready() -> void:
		
	for room in get_tree().get_nodes_in_group("rooms"):
		if room.name == "SafeRoom":
			Globals.current_scene = room
			break
			
	Globals.enable_room()

	room_manager.match_doors("SafeRoom","HallWay1")
	room_manager.match_doors("Test","HallWay1")

	#var door_scene = preload("res://Cenas/Objects/door/door.tscn")
	#var door = door_scene.instantiate()
	#door.position = Vector2(900, 300)  # posição da porta no cenário
	#add_child(door)
	
	#Jeito de setar um monstro a um spawner
	#var fSpawn = get_node("SpawnFantasm") as Spawn
	#fSpawn.set_enemie(preload("res://Cenas/Enemie/Fantasm/Fantasm.tscn"))
	
	player.armor.set_activate(false);
	
	
func _process(_delta: float) -> void:
	infosMode()		
	toggle_activate_armor()
		
func toggle_activate_armor() -> void:
	if Input.is_action_just_pressed("ui_toggle_armor"):
		player.armor.set_activate(activateArmor)
		activateArmor = !activateArmor
		
func infosMode():
	if(!infosModeActivate):
		var labelPlayer = Label.new()
		labelPlayer.name = "labelPlayer"

		add_child(labelPlayer)
		infosModeActivate = true
		
	for i in get_children():
		
		if i.name == "labelPlayer":
			var label = i as Label
			label.text =  ("""
			Life: %.0f
			Armor energie: %.0f
			""" % [player.life, player.armor.energie])
		
			
func createLabelLog() -> Array[Label]:
	
	var labelP = Label.new()
	labelP.name = "labelPlayer"
	
	var labelE = Label.new()
	labelE.name = "labelEnemie"
	
	
	var labels: Array[Label] = [labelP, labelE]
	
	return labels
	
