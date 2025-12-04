extends Node3D
class_name RouletteWheel

var 반지름 :float
var 깊이 :float
var cell_list :Array[RouletteCell]

func init(r :float, d: float, cell정보목록 :Array =[]) -> RouletteWheel:
	반지름 = r
	깊이 = d
	$"칸통".rotation.x = PI/2
	for n in cell정보목록:
		cell추가하기(n[0], n[1])
	cell위치정리하기()
	return self

func cell들지우기() -> void:
	for i in cell_list.size():
		$"칸통".remove_child(cell_list[i])
	cell_list = []

# 추가로 cell위치정리하기() 호출할것.
func cell추가하기(co :Color, t :String) -> void:
	var 칸rad = 2*PI/(cell_list.size()+1)
	var l = preload("res://roulette/roulette_cell/roulette_cell.tscn").instantiate().init(칸rad, 반지름, 깊이, co , t)
	l.position.z = 깊이/2
	$"칸통".add_child(l)
	cell_list.append(l)

func 마지막cell지우기() -> void:
	if cell_list.size() <= 0:
		return
	var n = cell_list.pop_back()
	$"칸통".remove_child(n)

# cell_list의 각도가 동일하게 조정한다.
func cell위치정리하기() -> void:
	if cell_list.size() == 0 :
		return
	var 칸rad = 2*PI/cell_list.size()
	for i in cell_list.size():
		cell_list[i].칸rad바꾸기(칸rad)
		var rad = 칸rad * i
		cell_list[i].rotation.y = -rad
		cell_list[i].글씨크기바꾸기()

func cell강조하기(i :int)->void:
	cell_list[i].강조상태켜기()

func cell강조끄기(i :int)->void:
	cell_list[i].강조상태끄기()

func cell_count얻기() -> int:
	return cell_list.size()

func cell얻기(i :int) -> RouletteCell:
	return cell_list[i]

func 각도로cell얻기(rad :float) -> RouletteCell:
	if cell_count얻기() == 0 :
		return null
	rad = fposmod(rad, 2*PI)
	var 칸rad = 2*PI / cell_count얻기()
	for 현재칸번호 in cell_count얻기():
		if 칸rad/2 + 현재칸번호*칸rad > rad:
			return cell얻기(현재칸번호)
	return cell얻기(0)
