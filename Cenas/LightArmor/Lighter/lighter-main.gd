extends LightArmor

func _ready() -> void:
	energie = 50
	
func _process(delta: float) -> void:
	energie_logic()
