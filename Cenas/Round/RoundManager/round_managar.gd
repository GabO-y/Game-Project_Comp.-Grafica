extends Node2D

class_name RoundManagar

@export var room_managar: RoomManager


var round_per_room: Dictionary = {}

func _ready() -> void:	
	room_managar.changed_room.connect(_check_round_room)
	

# toda vez que é trocado de sala, ele verifica
# se naquela sala tem um round agendado, se sim
# ele toca o round
func _check_round_room(room: Room):
	if room.has_rounds():
		room.start_round()
		
		
# ao final de cada instrução, é necessario uma virgula
func add_round(room_name: String, instrucs: String):
	
	var regex = RegEx.new()
	regex.compile(r"(.*),+")
	
	var result = regex.search_all(instrucs)
	
	var seq_instruc: Array[String]
	
	for matches in result:
		seq_instruc.append(matches.strings[1])
		
	regex.compile(r"([a-z]*)\s*\{([^}]*)\}")
		
	var round = load("res://Cenas/Round/Round.tscn").instantiate() as Round
	
	for inst in seq_instruc:
		
		result = regex.search(inst)
		
		var type: String = result.get_string(1)	
		
		var content: Array[String] = []

		if result.get_string(2).contains(","):
			for s in result.get_string(2).split(","):
				s.replace(" ", "")
				content.append(s)
		else:
			var s = result.get_string(2).replace(" ", "")
			content.append(s)

		match type:
			"horder":

				var ene_name: String = content[0]
				var quantity: int = content[1] as int
				var delay: float = content[2] as float
				
				#print("horder:")
				#print("\t", ene_name)
				#print("\t", quantity)
				#print("\t", delay)
				
				
				round.add_horder(
					ene_name, quantity, delay
				)
				
			"await":
				var time: float = content[0] as float
				
				#print("await:")
				#print("\t", time)
				
				round.await_time(time)
				
	var room = room_managar.find_room(room_name)
	
	round.set_room(room)
		
	
	
	
