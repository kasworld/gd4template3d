extends Node3D
class_name ReelSymbol

var 번호 :int

func init(n :int, sz :Vector2, r :float, color_text_info :Array) -> ReelSymbol:
	번호 = n
	$"글".mesh.text = color_text_info[1]
	$"글".mesh.font_size = sz.y*10
	$"글".mesh.material.albedo_color = color_text_info[0]
	$"글".position.z = r
	return self

func 글내용얻기() -> String:
	return $"글".mesh.text
