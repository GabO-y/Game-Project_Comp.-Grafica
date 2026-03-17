extends Sprite2D
var a = false
func _draw() -> void:
	if a:
		draw_line(global_position, Globals.player_pos(), Color.RED, 10.0)
