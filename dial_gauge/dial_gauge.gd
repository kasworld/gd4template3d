extends Node3D
class_name DialGauge

static var font := preload("res://font/HakgyoansimBareondotumR.ttf")
static func new_text(fsize :float, fdepth :float, mat :Material, text :String) -> MeshInstance3D:
	var mesh := TextMesh.new()
	mesh.font = font
	mesh.depth = fdepth
	mesh.pixel_size = fsize / 16
	mesh.text = text
	mesh.material = mat
	var sp := MeshInstance3D.new()
	sp.mesh = mesh
	return sp

var value_range :Array # [from, to] not min max
var rad_range :Array # [from, to] not min max

func clamp_value(v :float) -> float:
	if value_range[0] < value_range[1]:
		return clampf(v, value_range[0] , value_range[1])
	return clampf(v, value_range[1] , value_range[0])

func value_range_len() -> float:
	return abs(value_range[0] - value_range[1])

func value_range_mid() -> float:
	return (value_range[0] + value_range[1]) /2

func init_range(v_range :Array, r_range :Array ) -> DialGauge:
	value_range = v_range
	rad_range = r_range
	return self

## center ZERO
var aabb :AABB

func init(radius :float, depth :float,
	case_color :Color = Color(1,1,1,0.5),
	center_color :Color = Color(0.5,0.5,0.5),
	needle_color :Color = Color.RED
	) -> DialGauge:
	var size := Vector3(radius*2,radius*2,depth)
	aabb = AABB(-size/2,size)
	init_case(radius, depth, case_color )
	init_center(radius/10, depth/2, center_color)
	init_needle(radius*0.9, depth*0.3, needle_color)
	return self

func init_case(radius :float, depth :float, co :Color) -> DialGauge:
	$Case.mesh.top_radius = radius
	$Case.mesh.bottom_radius = radius
	$Case.mesh.height = depth
	$Case.mesh.material.albedo_color = co
	return self

func init_center(radius :float, depth :float, co :Color) -> DialGauge:
	$Center.mesh.top_radius = radius
	$Center.mesh.bottom_radius = radius
	$Center.mesh.height = depth
	$Center.mesh.material.albedo_color = co
	return self

func init_needle(radius :float, depth :float, co :Color) -> DialGauge:
	$NeedleBase/Needle.mesh.size = Vector3(radius, depth, depth)
	$NeedleBase/Needle.position = Vector3(radius/2,0,0)
	$NeedleBase/Needle.mesh.material.albedo_color = co
	return self

func add_dial_num(r :float, d:float, fsize :float, step_count :int, co :Color ) -> DialGauge:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = co
	var rad_step :float = float(rad_range[1] - rad_range[0]) / float(step_count)
	var value_step :float = (value_range[1] - value_range[0]) / float(step_count)
	for i in step_count+1:
		var val :float = value_range[0] + value_step*i
		var rad :float = rad_range[0] + rad_step * i
		var t := new_text(fsize, d, mat, "%.1f" % [val])
		t.position = Vector3(cos(rad)*r, sin(rad)*r, 0)
		$NumberContainer.add_child(t)
	return self

enum BarAlign {In,Mid,Out}
func add_dial_bar(r :float, bar_size :Vector3, align :BarAlign, step_count :int, co :Color) -> DialGauge:
	var pfl := preload("res://prop_focus_lines/prop_focus_lines.tscn").instantiate()
	pfl.init(r,bar_size,align,step_count,rad_range,co)
	add_child(pfl)
	return self

func set_needle_value(v :float) -> void:
	#v = clampf(v, value_range[0], value_range[1])
	var rate :float = (v- value_range[0]) / (value_range[1]- value_range[0])
	var rad :float = (rad_range[1]- rad_range[0])*rate + rad_range[0]
	$NeedleBase.rotation.z = rad
