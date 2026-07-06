extends Node3D
class_name 말

enum 위치 {달말통, 판위눈, 이동중, 난말통}

var 속한편 :YutTeam
var 말번호 :int
var 지나온눈번호들 :Array[int]
var 말위치 :위치

func string_debug() -> String:
	var s :String = ""
	for n in 지나온눈번호들:
		s += "%d " % n
	return "말(%s %d 눈[%s])" % [속한편,말번호,s]

func _to_string() -> String:
	return "%s말%d" % [속한편,말번호]

func debug_str() -> String:
	return "%s말%d %s %s" % [속한편, 말번호, 위치.keys()[말위치], 지나온눈번호들]

func init(t :YutTeam, 반지름 :float, 높이 :float, n:int) -> 말:
	속한편 = t
	말번호 = n
	반지름 = 반지름*1.0 * t.인자.크기보정
	var shape:=모양만들기(반지름, 높이, n, t.인자.색, t.인자.모양)
	shape.rotate_x(PI/2)
	add_child(shape)
	달말로만들기()
	return self

static func 모양만들기(반지름 :float, 높이 :float, n:int, co :Color, side :int) -> MeshInstance3D:
	var center := CSG.MakeDummyCenter()
	CSG.AddCoinCSG(center, 반지름, 높이, CSG.MakeColorMaterial(co, false), side)
	CSG.SubCoinCSGFrontBack(center, 반지름*0.9, 높이/2, 높이/2, CSG.MakeColorMaterial(co.darkened(0.2), false), side)
	CSG.AddCoinTextCSG(center, 반지름, 높이/4, 높이*0.5, CSG.MakeColorMaterial(co.lightened(0.2), false), "%s" % n, "%s" % n)
	return CSG.DefferedBake(center)

func 초기상태인가() -> bool:
	return 말위치 == 위치.달말통 and 지나온눈번호들.is_empty()

func 상태검사() -> String:
	if 달말인가() or 난말인가():
		if not 지나온눈번호들.is_empty():
			return "말의 지나온눈번호들이 비어있지않다. %s" % [debug_str() ]
	return ""

func 편얻기() -> YutTeam:
	return 속한편

func 같은편인가(m :말) -> bool:
	return 속한편 == m.편얻기()

func 마지막눈번호() -> int:
	return 지나온눈번호들[-1]

func 난말로만들기() -> void:
	말위치 = 위치.난말통
	지나온눈번호들 = []

func 난말인가() -> bool:
	return 말위치 == 위치.난말통

func 달말로만들기() -> void:
	말위치 = 위치.달말통
	지나온눈번호들 = []

func 달말인가() -> bool:
	return 말위치 == 위치.달말통

func 판위말로만들기() -> void:
	말위치 = 위치.판위눈

func 판위말인가() -> bool:
	return 말위치 == 위치.판위눈

func 이동말로만들기() -> void:
	말위치 = 위치.이동중

func 이동말인가() -> bool:
	return 말위치 == 위치.이동중

func 말위치얻기() -> 위치:
	return 말위치
