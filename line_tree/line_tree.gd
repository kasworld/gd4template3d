extends Node3D
class_name LineTree

func init(h :float, w :float, co1 :Color, co2 :Color, line_width :float = 0.5, stage_count :int=5) -> LineTree:
	$"중심기둥".mesh.top_radius = w/1000
	$"중심기둥".mesh.bottom_radius = w/100
	$"중심기둥".mesh.height = h
	$"중심기둥".mesh.material.albedo_color = co2
	$"중심기둥".position.y = h /2
	var lines := []
	for y in range(h,0,-1):
		var rate := (h-y)/h
		var r :float= lerp(1.0, w/2, rate ) + fposmod(rate*h, h/stage_count)*rate
		lines.append_array(make_lines(y,w*1.5*(rate+0.1),10*rate,r))
	$Lines.multi_line_by_pos(lines, line_width, Color.WHITE)
	$Lines.set_gradient_color_all(co1,co2)
	return self

func make_lines(start_y :float, count :int, h :float, r :float) -> Array:
	var rtn := []
	var rad_step := 2*PI / count
	var end_y := start_y+h
	var rad_shift :float = randf_range(0,rad_step)
	for i in count:
		var rad := rad_step*i + rad_shift
		var to := Vector3(cos(rad)*r, start_y  , sin(rad)*r)
		rtn.append([Vector3(0,end_y,0), to])
	return rtn
