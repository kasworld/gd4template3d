extends Node3D
class_name LineTree


func get_lines() -> MultiMeshShape:
	return $Lines

func set_center_color(center_color :Color) -> LineTree:
	$"중심기둥".mesh.material.albedo_color = center_color
	return self

func set_gradient_color( co1 :Color, co2 :Color) -> LineTree:
	$Lines.set_gradient_color_all(co1,co2)
	return self

func init(h :float, w :float, y_count :int, line_width :float = 0.5, stage_count :int=5) -> LineTree:
	$"중심기둥".mesh.top_radius = w/1000
	$"중심기둥".mesh.bottom_radius = w/100
	$"중심기둥".mesh.height = h
	$"중심기둥".position.y = h /2
	var lines := []
	var y_step := h / y_count
	for yi in range(y_count,0,-1):
		var y := y_step * yi
		var rate := 1-float(yi) / float(y_count)
		var r :float= lerp(w/100, w/2, rate ) + fposmod(rate*h, h/stage_count)*rate
		lines.append_array(make_lines(y, y_step, w*1.5*(rate+0.1), 10*rate,r))
	$Lines.multi_line_by_pos(lines, line_width, Color.WHITE)
	return self

func make_lines(start_y :float, y_step :float, count :int, h :float, r :float) -> Array:
	instance_count_per_y.append(count)
	var rtn := []
	var rad_step := 2*PI / count
	var end_y := start_y+h
	var rad_shift :float = randf_range(0,rad_step)
	for i in count:
		var rad := rad_step*i + rad_shift
		var y_shift := randf_range(-y_step/2, y_step/2)
		var to := Vector3(cos(rad)*r, start_y + y_shift, sin(rad)*r)
		rtn.append([Vector3(0, end_y+ y_shift, 0), to])
	return rtn

var instance_count_per_y :Array[int] = []
func make_index_array() -> Array:
	var rtn := []
	var i := 0
	for count in instance_count_per_y:
		var index_array := []
		for j in count:
			index_array.append(i)
			i += 1
		rtn.append(index_array)
	return rtn
