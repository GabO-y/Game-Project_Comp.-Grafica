extends Node2D

@onready var player := $Player
@onready var enemies: Array[Enemie]


var activateArmor = true
var armor: LightArmor
var infosModeActivate = false
var spawns: Array[Spawn] = []

func _ready() -> void:
	
	var fSpawn = get_node("SpawnFantasm") as Spawn
	fSpawn.set_enemie(preload("res://Cenas/Enemie/Fantasm/Fantasm.tscn"))
		
	armor = player.armor
	armor.set_activate(false);
	
	spawns = [fSpawn]
	
		
		
func _process(delta: float) -> void:
	
	
	
	infosMode()		
	
	toggle_activate_armor()
		
func toggle_activate_armor() -> void:
	if Input.is_action_just_pressed("ui_toggle_armor"):
		armor.set_activate(activateArmor)
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
			""" % [player.life, armor.energie])
		
			
func createLabelLog() -> Array[Label]:
	
	var labelP = Label.new()
	labelP.name = "labelPlayer"
	
	var labelE = Label.new()
	labelE.name = "labelEnemie"
	
	
	var labels: Array[Label] = [labelP, labelE]
	
	return labels
		
	
