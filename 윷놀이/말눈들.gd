extends Node3D
class_name 말눈들

const 눈사이각도 = 360.0/20.0
var 눈들 :Array[눈]

func init(반지름: float, 높이 :float, 색깔 :Color) -> 말눈들:
	var 눈반지름 = 반지름/30

	# 눈 추가하기
	for i in range(눈사이각도, 360+눈사이각도, 눈사이각도):
		var rd = deg_to_rad(i)
		var pos = Vector3(sin(rd)*반지름, cos(rd)*반지름, 0) # PolygonNode.make_pos_by_rad_r_3d(rd,반지름)
		눈추가(눈반지름, 높이, pos, 색깔)

	for i in [0.66,0.33,0,-0.33,-0.66]:
		눈추가(눈반지름, 높이, Vector3(반지름*i,0,0),색깔)

	for i in [-0.66,-0.33,0.33,0.66]:
		눈추가(눈반지름, 높이, Vector3(0,반지름*i, 0),색깔)

	return self

func 눈추가(눈반지름: float, 높이:float, pos:Vector3, 색깔:Color):
	var 눈1 = preload("res://윷놀이/눈.tscn").instantiate()
	눈1.init(눈반지름, 높이, 색깔, 눈들.size())
	눈1.position = pos
	add_child(눈1)
	눈들.append(눈1)

func 눈얻기(눈번호 :int)->눈:
	return 눈들[눈번호]

func 눈번호보기(b :bool):
	for n in 눈들:
		n.눈번호보기(b)

func 눈번호들을좌표로(눈번호들 :Array[int])->Array[Vector3]:
	var 좌표들 :Array[Vector3] = []
	for i in 눈번호들:
		좌표들.append(눈들[i].position )
	return 좌표들
