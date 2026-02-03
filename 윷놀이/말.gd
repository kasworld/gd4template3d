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

func init(t :YutTeam, 반지름 :float, 높이 :float, n:int, hide_num :bool = false) -> 말:
	속한편 = t
	말번호 = n
	반지름 = 반지름*1.0 * t.인자.크기보정
	$"다각기둥".init(반지름, 높이, t.인자.색, t.인자.모양)
	$"번호".text = "%d" % 말번호
	$"번호".visible = not hide_num
	$"번호".modulate = t.인자.색
	$"번호".pixel_size = 반지름 /30
	#$"번호".position.z = 높이
	달말로만들기()
	return self

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

func 마지막눈번호()->int:
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
