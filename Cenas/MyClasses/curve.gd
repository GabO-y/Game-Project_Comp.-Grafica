extends Node2D

class_name MyCurve
	
var p0: Vector2
var p1: Vector2
var p2: Vector2	
var t: float = 0.01

var is_redraw = false
	
var progress:float = 0.0

var need_calculate = false

var curve: Array[Vector2]

func _init(
	p0: Vector2 = Vector2.ZERO,
	p1: Vector2 = Vector2.ZERO, 
	p2: Vector2 = Vector2.ZERO,
	t: float = 0.01
	) -> void:
	
	self.p0 = p0
	self.p1 = p1
	self.p2 = p2
	self.t = t
	
	calculate_curve()
				
func set_t(t: float):
	self.t = t
	need_calculate = true

func set_p0(p0: Vector2):
	self.p0 = p0
	need_calculate = true
func set_p1(p1: Vector2):
	self.p1 = p1
	need_calculate = true
func set_p2(p2: Vector2):
	self.p2 = p2
	need_calculate = true
func get_curve() -> Array[Vector2]:
			
	if need_calculate:
		calculate_curve()
		need_calculate = false
		
	return curve
	
func calculate_curve():
	
	curve.clear()
	var time: float = 0.0
	while time < 1:
		time += t
		var q0 = p0.lerp(p1, time)
		var q1 = p1.lerp(p2, time)
		var r = q0.lerp(q1, time)
		curve.append(r)
		
	need_calculate = false
	return curve
		
func get_point(t: float):
	
	curve = get_curve()
	
	if t <= 0:
		return curve.get(0)
	if t >= 1:
		return curve.get(curve.size() - 1)
		
	return curve.get(t * curve.size())
	
func get_point_by_progress():
	
	if progress >= 1:
		progress_finish.emit()
		progress = 0
	
	var p = get_point(progress)
	progress += t
	
	return p
	
func drop_effect(start: Vector2, right: bool, wigth: float = 5.0, heith: float = 5.0):
	
	var p0 = start
	var p1 = start
	var p2 = start
	
	var x
	var y
	
	p1.y -= 1 * heith
	
	x = (1 * wigth) / 2
	
	if not right:
		x = -x
	
	p1.x += x
	x = (1 * wigth) / 2
	
	if not right:
		x = -x
	
	p2.x += x
	p2.y += (1 * heith) / 2

	set_p0(p0)
	set_p1(p1)
	set_p2(p2)
	
	calculate_curve()
	
func _draw() -> void:
	
	for p in curve:
		draw_circle(p, 3, Color.GREEN)
		
	draw_circle(p0, 3, Color.RED)
	draw_circle(p1, 3, Color.RED)
	draw_circle(p2, 3, Color.RED)

		
	
signal progress_finish
