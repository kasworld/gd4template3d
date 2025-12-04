extends Node3D
class_name RouletteWheel

signal rotation_stopped(rl :RouletteWheel)

var 반지름 :float
var 깊이 :float
var cell_list :Array[RouletteCell]
var cell각도 :float
func init(r :float, d: float, color_text_info_list :Array) -> RouletteWheel:
	반지름 = r
	깊이 = d
	$"칸통".rotation.x = PI/2
	var count := color_text_info_list.size()
	cell각도 = 2*PI / count
	for i in count:
		var k :RouletteCell = preload("res://roulette/roulette_cell/roulette_cell.tscn").instantiate().init(cell각도, 반지름, 깊이, color_text_info_list[i])
		k.position.z = 깊이/2
		k.rotation.y = cell각도 *i
		$"칸통".add_child(k)
		cell_list.append(k)
	return self

func _process(delta: float) -> void:
	if 회전중인가:
		돌리기(delta)

var 회전중인가 :bool # need emit
var rotation_per_second :float
var acceleration := 0.3 # per second
func 돌리기(dur_sec :float = 1.0) -> void:
	rotation.z += rotation_per_second * 2 * PI * dur_sec
	if acceleration > 0:
		rotation_per_second *= pow( acceleration , dur_sec)
	if 회전중인가 and (abs(rotation_per_second) <= 0.1 and cell중심근처인가(rotation.z)) or (abs(rotation_per_second) <= 0.01):
		회전중인가 = false
		rotation_per_second = 0.0
		rotation_stopped.emit(self)

# spd : 초당 회전수
func 돌리기시작(spd :float) -> void:
	rotation_per_second = spd
	회전중인가 = true

func 멈추기시작(accel :float=0.5) -> void:
	assert(accel < 1.0)
	acceleration = accel

func cell들지우기() -> void:
	for i in cell_list.size():
		$"칸통".remove_child(cell_list[i])
	cell_list = []

func cell강조하기(i :int)->void:
	cell_list[i].강조상태켜기()

func cell강조끄기(i :int)->void:
	cell_list[i].강조상태끄기()

func cell_count얻기() -> int:
	return cell_list.size()

func cell얻기(i :int) -> RouletteCell:
	return cell_list[i]

func 각도로cell얻기(rad :float) -> RouletteCell:
	return cell얻기( 각도로cell번호얻기(rad) )

func 각도로cell번호얻기(rad :float) -> int:
	var 현재각도 = fposmod(-rad, 2*PI)
	return ceili( (현재각도-cell각도/2) / cell각도 ) % cell_list.size()

func cell중심각도(cell번호 :int) -> float:
	return cell각도 * cell번호

func cell중심근처인가(rad :float) -> bool:
	var 현재cell번호 := 각도로cell번호얻기(rad)
	var 현재각도 = fposmod(-rad, 2*PI)
	var 중심각도 = cell중심각도(현재cell번호)
	return abs(현재각도 - 중심각도 - cell각도/2) <= cell각도/100
