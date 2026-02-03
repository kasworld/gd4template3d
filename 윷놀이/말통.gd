extends Node3D

class_name 말통

var 반지름 :float
var 높이 :float
var 넣을반경크기 :float
var 넣을높이범위 :Vector2

func init(반지름a :float, 높이a :float, 색깔 :Color, 각수 := 64, 넣을크기반지름비율 := 1.0, 넣을높이범위비율 :=Vector2(0.5,1.0) ) -> 말통:
	반지름 = 반지름a
	높이 = 높이a
	$"모양".init(반지름, 높이, 색깔, 각수)
	넣을공간설정(반지름*넣을크기반지름비율,높이*넣을높이범위비율)
	return self

# 인자가 비율이 아닌 크기임.
func 넣을공간설정(넣을반경크기a :float, 넣을높이범위a :Vector2) -> 말통:
	넣을반경크기 = 넣을반경크기a
	넣을높이범위 = 넣을높이범위a
	return self

func 설명달기(설명 :String, 크기 :float,  위치 := Vector3.ZERO, 설명색깔 := Color.WHITE) -> 말통:
	$"설명".text = 설명
	$"설명".position = 위치
	$"설명".modulate = 설명색깔
	$"설명".pixel_size = 크기
	return self

func 설명보기(b :bool) -> void:
	$"설명".visible = b

func 말들넣기(넣을말들 :Array[말]) -> void:
	for m in 넣을말들:
		말넣기(m)

func 말넣기(넣을말 :말) -> void:
	$"말들".add_child(넣을말)
	넣을말.position = rand_circle(넣을반경크기, 넣을높이범위)

func 말모두빼기() -> Array[말]:
	var rtn :Array[말]
	for m in $"말들".get_children():
		rtn.append(m)
		$"말들".remove_child(m)
	return rtn

func 말빼기(m :말) -> void:
	$"말들".remove_child(m)

func 말보기() -> Array[말]:
	var rtn :Array[말]
	for m in $"말들".get_children():
		rtn.append(m)
	return rtn

func 말이있나(ma :말) -> bool:
	for m in $"말들".get_children():
		if m == ma:
			return true
	return false

func rand_circle(r :float, hrange :Vector2) -> Vector3:
	var l = randf_range(0,r)
	var rad = randf_range(0,2*PI)
	return Vector3(sin(rad)*l, cos(rad)*l, randf_range(hrange[0],hrange[1]) )
