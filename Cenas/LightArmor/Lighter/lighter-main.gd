extends LightArmor

func _ready() -> void:
	energie = 50
	super._ready()
	
func _process(delta: float) -> void:
	energie_logic()
	super._process(delta)
