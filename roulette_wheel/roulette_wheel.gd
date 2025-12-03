extends Node3D
class_name RouletteWheel

signal rotation_stopped(n :int)

var 선택rad :float = 0.0
var id :int
var 반지름 :float
var 깊이 :float
var cell_list :Array[RouletteCell]
var 회전중인가 :bool # need emit

func init(ida :int, 반지름a :float, 깊이a :float,
		원판색 :Color = Color.DARK_GREEN,
		장식색 :Color = Color.GOLD,
		장식팔개수 :int = 4,
		화살표색 :Color = Color.WHITE,
		) -> RouletteWheel:
	id = ida
	반지름 = 반지름a
	깊이 = 깊이a

	# for debug
	$IDLabel.text = "%s" % id
	#$IDLabel.font_size = 반지름/5
	$IDLabel.outline_size = 반지름/20
	$IDLabel.pixel_size = 반지름/100

	$"돌림/원판".mesh.height = 깊이
	$"돌림/원판".mesh.bottom_radius = 반지름
	$"돌림/원판".mesh.top_radius = 반지름
	$"돌림/원판".mesh.material.albedo_color = 원판색
	$"돌림/원판".position.z = -깊이
	$"돌림/원판".rotation.x = PI/2
	$"돌림/칸통".rotation.x = PI/2

	$"돌림/ValveHandle".init(반지름*0.1, 반지름*0.1, 장식팔개수, 장식색)
	$"돌림/ValveHandle".rotation.x = PI/2

	var rot = 0
	$"돌림/BarTree2".init_common_params(반지름*0.5, 깊이, 반지름*0.05, 256, rot, 선택rad, 1.0, false
		).init_with_color(장식색, 원판색)
	$"돌림/BarTree2".position.z = 깊이/2
	$"돌림/BarTree2".rotation.x = PI/2

	$"돌림/BarTree3".init_common_params(반지름*0.5, 깊이, 반지름*0.05, 256, rot, 선택rad +PI, 1.0, false
		).init_with_color(장식색.inverted(), 원판색.inverted())
	$"돌림/BarTree3".position.z = 깊이/2
	$"돌림/BarTree3".rotation.x = PI/2

	$화살표.set_size(반지름/5,깊이/2, 깊이*1.5,0.5).set_color(화살표색)
	선택rad바꾸기(선택rad)
	return self

func 선택rad바꾸기(rad :float) -> void:
	$화살표.rotation = Vector3(0, 0, PI-rad)
	$화살표.position = Vector3(sin(rad) *반지름*1.1, cos(rad) *반지름*1.1, 0 )

func 색바꾸기(원판색 :Color, 장식색 :Color, 화살표색 :Color) -> void:
	$"돌림/원판".mesh.material.albedo_color = 원판색
	$"돌림/ValveHandle".색바꾸기(장식색)
	$"화살표".색바꾸기(화살표색)

var rotation_per_second :float
var acceleration := 0.3 # per second
func 돌리기(dur_sec :float = 1.0) -> void:
	$"돌림".rotation.z += rotation_per_second * 2 * PI * dur_sec
	if acceleration > 0:
		rotation_per_second *= pow( acceleration , dur_sec)
	if 회전중인가 and abs(rotation_per_second) <= 0.001:
		회전중인가 = false
		rotation_per_second = 0.0
		rotation_stopped.emit(id)
	$"돌림/BarTree2".bar_rotation = -rotation_per_second/10
	$"돌림/BarTree3".bar_rotation = -rotation_per_second/10

func 선택된cell강조상태켜기() -> void:
	var 선택칸 = 선택된cell얻기()
	if 선택칸 != null:
		선택칸.강조상태켜기()

# spd : 초당 회전수
func 돌리기시작(spd :float) -> void:
	rotation_per_second = spd
	회전중인가 = true
	$"돌림/BarTree2".auto_rotate_bar = true
	$"돌림/BarTree2".bar_rotation = -spd/10
	$"돌림/BarTree3".auto_rotate_bar = true
	$"돌림/BarTree3".bar_rotation = -spd/10

func 멈추기시작(accel :float=0.5) -> void:
	assert(accel < 1.0)
	acceleration = accel

func cell들지우기() -> void:
	for i in cell_list.size():
		$"돌림/칸통".remove_child(cell_list[i])
	cell_list = []

# 추가로 cell위치정리하기() 호출할것.
func cell추가하기(co :Color, t :String) -> void:
	var 칸rad = 2*PI/(cell_list.size()+1)
	var l = preload("res://roulette_wheel/roulette_cell/roulette_cell.tscn").instantiate().init(칸rad, 반지름, 깊이, co , t)
	l.position.z = 깊이/2
	$"돌림/칸통".add_child(l)
	cell_list.append(l)

func 마지막cell지우기() -> void:
	if cell_list.size() <= 0:
		return
	var n = cell_list.pop_back()
	$"돌림/칸통".remove_child(n)

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
	$"돌림/원판".mesh.radial_segments = cell_list.size()
	$"돌림/BarTree2".set_visible_bar_count(cell_list.size())
	$"돌림/BarTree3".set_visible_bar_count(cell_list.size())

func 선택된cell얻기() -> RouletteCell:
	if cell_list.size() == 0 :
		return null
	var rad = $"돌림".rotation.z - 선택rad - PI/2
	rad = fposmod(rad, 2*PI)
	var 칸rad = 2*PI / cell_list.size()
	for 현재칸번호 in cell_list.size():
		if 칸rad/2 + 현재칸번호*칸rad > rad:
			return cell_list[현재칸번호]
	return cell_list[0]

func cell강조하기(i :int)->void:
	cell_list[i].강조상태켜기()

func cell강조끄기(i :int)->void:
	cell_list[i].강조상태끄기()

func cell_count얻기() -> int:
	return cell_list.size()

func cell얻기(i :int) -> RouletteCell:
	return cell_list[i]
