extends TextureRect

class_name PowerUpMenuItem


@export var button: Button
@export var progress_bar: ProgressBar


var menu: PowerUpMenu
var power_up: PowerUp

var is_pressed: bool = false
var frames: int = 0

func _ready() -> void:
	button.button_down.connect(
		func():
			is_pressed = true
	)
	button.button_up.connect(
		func():
			is_pressed = false
	)
	
func _process(delta: float) -> void:
	if is_pressed:
		if not progress_bar.visible:
			progress_bar.visible = true
		progress_bar.value = frames as float / menu.select_frames as float 
		frames += 1
		if frames > menu.select_frames:
			power_up.apply()
			menu.setup_state(Menu.MenuState.DESABLE)
			queue_free()
			return
	else:
		if frames > 0:
			frames = 0
		if progress_bar.visible:
			progress_bar.visible = false
