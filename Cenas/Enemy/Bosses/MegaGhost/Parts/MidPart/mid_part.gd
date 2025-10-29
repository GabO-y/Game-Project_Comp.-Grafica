extends Part

class_name MidPart

func split():
	var parts = super.split() as Array[Part]
	parts[0].is_min_min = false
	parts[1].is_min_min = false
