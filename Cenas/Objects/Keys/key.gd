extends Item

class_name Key

var what_open: Array[String]

static func generate_key(name: String) -> Item:
	var key = Key.new()
	
	var rooms_name = name.split(",") 
	
	key.what_open.append(str(rooms_name[0]))
	key.what_open.append(str(rooms_name[1]))

	key.name = name

	return key
	
func equals(key: Key):
	if what_open[0] == key.what_open[0] and what_open[1] == key.what_open[1]:
		return true
	if what_open[0] == key.what_open[1] and what_open[1] == key.what_open[0]:
		return true
	return false
