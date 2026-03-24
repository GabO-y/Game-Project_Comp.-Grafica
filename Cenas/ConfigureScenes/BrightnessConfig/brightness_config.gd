extends HScrollBar

class_name BrightnessConfig

@export var filter_exemple: CanvasModulate

func _ready() -> void:
	await get_tree().process_frame
	value_changed.emit(0.5)

func _on_value_changed(value: float) -> void:	
	Globals.global_brightness = value
	Globals.update_brightness()
	filter_exemple.color = Globals.backlayer_filter.color
