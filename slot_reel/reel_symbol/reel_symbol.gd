extends Node3D
class_name ReelSymbol

func init(크기 :float, r :float, color_text_info :Array) -> ReelSymbol:
	$"글".mesh.text = color_text_info[1]
	$"글".mesh.pixel_size = 크기/18
	$"글".mesh.depth = 크기/40
	$"글".mesh.material.albedo_color = color_text_info[0]
	$"글".position.z = r
	return self

func 글내용얻기() -> String:
	return $"글".mesh.text
