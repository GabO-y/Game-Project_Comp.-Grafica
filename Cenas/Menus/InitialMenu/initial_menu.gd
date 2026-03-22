extends Menu

class_name InitialMenu

@export var anim: AnimationPlayer
@export var anim_control_node: Control
@export var control_node: Control

@export var start_button: Button

var stage: int = 1

func setup_state(state: MenuState):
	match state:
		MenuState.ENABLE:
			visible = true
			control_node.visible = true
			anim_control_node.visible = false
			Globals.player.setup_state(Player.PlayerState.MENU)
			start_button.grab_focus()
		MenuState.DESABLE:
			visible = false
			anim_control_node.visible = false
			for c in anim.animation_finished.get_connections():
				anim.animation_finished.disconnect(c["callable"])
			Globals.player.setup_state(Player.PlayerState.MOVING)
			anim.stop()
	current_state = state

func start():
	
	for c in anim.animation_finished.get_connections():
		anim.animation_finished.disconnect(c["callable"])
		
	set_visible_control(control_node, true)
	set_visible_control(anim_control_node, false)
	
	Globals.player.set_active(false)
	
func _on_start_button_down() -> void:
	
	anim_control_node.visible = true
	
	for i in anim.animation_finished.get_connections():
		anim.animation_finished.disconnect(i["callable"])

	anim.play("start")
	anim.animation_finished.connect(
		func(_n):
			control_node.visible = false
			anim.play("start2")
			anim.animation_finished.connect(
				func(_m):
					setup_state(MenuState.DESABLE)
					start_play.emit()
			)
	)
	
func set_visible_control(control_node: Control, mode: bool):
	control_node.visible = mode
	
func _on_tutorial_button_down() -> void:
	if anim.is_playing(): return
	setup_state(MenuState.DESABLE)
	Globals.house.tutorial_menu.setup_state(MenuState.ENABLE)

func exit() -> void:
	if anim.is_playing(): return
	get_tree().quit()

signal start_play
