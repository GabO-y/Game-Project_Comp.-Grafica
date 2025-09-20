extends Control

@onready var label = $Main

var player: Player
var spawans: Array[Spawn]

func _process(delta: float) -> void:
	
	var player_text := ""
		
	if player != null:
		player_text = str("Player:\n\tLife: %s\n\tArmor: %s (%d)" % [player.life, player.armor.name, player.armor.energie])
		
	for spawn in Globals.current_scene.get_children():
		if spawn is Spawn:
			spawans.append(spawn)
					
	var spawn_text := ""
	
	if !spawans.is_empty():
		
		for s in spawans:
			spawn_text += str("%s\n" % s.name)
			for e in s.enemies:
				spawn_text += "%s: %s\n" % [e.name, e.life]
	else:
		spawn_text = "Room clean"
		
	label.text = player_text + "\n" + spawn_text
		
	spawans.clear()
