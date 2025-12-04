extends Node3D
class_name ReelSymbol

var 글내용 :String
var 번호 :int

func init(n :int, sz :Vector2, r :float, color_text_info :Array) -> ReelSymbol:
	번호 = n
	글내용 = color_text_info[1]
	$"글".mesh.text = 글내용
	$"글".mesh.font_size = sz.y*10
	$"글".mesh.material.albedo_color = color_text_info[0]
	$"글".position.z = r
	return self
