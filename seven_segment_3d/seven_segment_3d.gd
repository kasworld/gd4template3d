extends Node3D
class_name SevenSegment3D

static func MakeColorMaterial(alpha :float = 1.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	# draw call 이 TRANSPARENCY_ALPHA 인 경우만 줄어든다. 버그인가?
	if alpha >= 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	else:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(Color.WHITE,alpha)
	mat.vertex_color_use_as_albedo = true

	#mat.metallic = 1.0
	##mat.roughness = 0.5
	#mat.clearcoat_enabled = true
	#mat.refraction_enabled = true
	#mat.rim_enabled = true
	return mat


const NumToFlag :Dictionary[int,int] = {
	0: 0b1111101,
	1: 0b1100000,
	2: 0b1001111,
	3: 0b1100111,
	4: 0b1110010,
	5: 0b0110111,
	6: 0b0111111,
	7: 0b1110100,
	8: 0b1111111,
	9: 0b1110111,
}

var full_size :Vector3
var segment_thick :float
var segment_list :Array[MeshInstance3D] = []

## face Z
func init(sz :Vector3, seg_w :float, co :Color) -> SevenSegment3D:
	full_size = sz
	segment_thick = seg_w
	var h_size := calc_H_segment_size()
	var v_size := calc_V_segment_size()
	for y in 3:
		var sg := make_segment( h_size, co )
		segment_list.append(sg)
		add_child(sg)
		sg.position = calc_H_segment_pos(y)
	for x in 2:
		for y in 2:
			var sg := make_segment( v_size, co )
			segment_list.append(sg)
			add_child(sg)
			sg.position = calc_V_segment_pos(x,y)
	return self

func show_segment_by_array(arr :Array[bool]) -> void:
	for i in arr.size():
		segment_list[i].visible = arr[i]

func show_segment_by_flag(flag :int) -> void:
	for i in segment_list.size():
		segment_list[i].visible = BitFlag.TestByPos(i, flag)


## face Z
func calc_H_segment_size() -> Vector3:
	var h_size := full_size.x - segment_thick*2
	return Vector3( h_size, segment_thick, full_size.z)

func calc_V_segment_size() -> Vector3:
	var v_size := (full_size.y - segment_thick*3)/2
	return Vector3( segment_thick, v_size, full_size.z)

## y : 0,1,2
func calc_H_segment_pos(y :int) -> Vector3:
	var y_pos :float = (y-1) * (full_size.y-segment_thick)/2
	return Vector3(0, y_pos, 0)

## x : 0,1  y : 0,1
func calc_V_segment_pos(x :int, y :int) -> Vector3:
	var x_pos :float = [-full_size.x/2+segment_thick/2, full_size.x/2-segment_thick/2][x]
	var v_seg_size := calc_V_segment_size()
	var y_pos :float = [-v_seg_size.y/2-segment_thick/2, v_seg_size.y/2+segment_thick/2][y]
	return Vector3(x_pos, y_pos, 0)

func make_segment(sz :Vector3, co :Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = BoxMesh.new()
	mi.mesh.size = sz
	mi.mesh.material = MakeColorMaterial(1.0)
	mi.mesh.material.albedo_color = co
	return mi
