extends Area2D

func _ready() -> void:
	body_entered.connect(self._on_body_entered)

func _on_body_entered(obj: Enemie):
	obj.take_damage(10)
	

	
