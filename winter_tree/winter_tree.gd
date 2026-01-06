extends Node3D
class_name WinterTree

func 가지들얻기() -> MultiMeshShape:
	return $가지들

func 장식들얻기() -> MultiMeshShape:
	return $장식들

func set_center_color(center_color :Color) -> WinterTree:
	$"중심기둥".mesh.material.albedo_color = center_color
	return self

func set_gradient_color( co1 :Color, co2 :Color) -> WinterTree:
	$가지들.set_gradient_color_all(co1,co2)
	return self

func init(h :float, w :float, y_count :int, w_branch_density :float = PI, line_width :float = 0.5, stage_count :int=5) -> WinterTree:
	$"중심기둥".mesh.top_radius = w/1000
	$"중심기둥".mesh.bottom_radius = w/100
	$"중심기둥".mesh.height = h
	$"중심기둥".position.y = h /2

	branch_list = []
	instance_count_per_y = []
	var y_step := h / y_count
	for yi in range(y_count,0,-1):
		var y := y_step * yi
		var rate := 1.0 - y/h
		var r :float= calc_radius_by_y(y, h, w, stage_count)
		branch_list.append_array(make_lines(y, y_step, r * w_branch_density, 10*rate, r))
	var bmesh := PrismMesh.new()
	bmesh.size = Vector3(1,0.3,1)
	$가지들.multi_mesh_line_by_pos(bmesh, branch_list, line_width, Color.WHITE)

	var pos_list := []
	for i in 500:
		var l = branch_list.pick_random()
		pos_list.append(l[1])
	var sp_mesh := SphereMesh.new()
	sp_mesh.radius = 0.5
	sp_mesh.height = 0.5*2
	$"장식들".init_meshs_by_point_list(sp_mesh, pos_list, Color.WHITE)

	return self

func calc_radius_by_y(y :float, h :float, w :float, stage_count :int) -> float:
	var rate := 1.0 - y/h
	return lerp(w/100, w/2, rate ) + fposmod(rate*h, h/stage_count)*rate

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

var branch_list :Array

var instance_count_per_y :Array[int]
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
