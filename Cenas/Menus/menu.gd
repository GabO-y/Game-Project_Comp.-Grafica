extends CanvasLayer

class_name Menu

@export var manager: MenuManager

	
func set_active(mode: bool):
		
	Globals.player.hud.visible = not mode
	
	get_tree().paused = mode
	set_process_unhandled_input(mode)
	
	visible = mode
	manager.is_in_menu = mode
	
	if mode:
		manager.current_menu = self
	else:
		if manager.current_menu == self:
			manager.current_menu = null
			
func reset():
	set_active(false)
		
		
