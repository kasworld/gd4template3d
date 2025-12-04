extends Node3D
class_name Roulette

signal rotation_stopped(n :int)

var 선택rad :float
var id :int
var 반지름 :float
var 깊이 :float
var 회전중인가 :bool # need emit

func init(ida :int, 반지름a :float, 깊이a :float, cell정보목록 :Array ) -> Roulette:
	id = ida
	반지름 = 반지름a
	깊이 = 깊이a

	$Wheel.init(반지름, 깊이, cell정보목록)

	# for debug
	$IDLabel.text = "%s" % id
	$IDLabel.outline_size = 반지름/20
	$IDLabel.pixel_size = 반지름/100

	$"Wheel/원판".mesh.height = 깊이
	$"Wheel/원판".mesh.bottom_radius = 반지름
	$"Wheel/원판".mesh.top_radius = 반지름
	$"Wheel/원판".position.z = -깊이
	$"Wheel/원판".rotation.x = PI/2

	$"Wheel/ValveHandle".init(반지름*0.1, 반지름*0.1, 4, Color.WHITE)
	$"Wheel/ValveHandle".rotation.x = PI/2

	$"Wheel/BarTree2".init_common_params(반지름*0.5, 깊이, 반지름*0.05, 256, 0, 0, 1.0, false)
	$"Wheel/BarTree2".position.z = 깊이/2
	$"Wheel/BarTree2".rotation.x = PI/2

	$"Wheel/BarTree3".init_common_params(반지름*0.5, 깊이, 반지름*0.05, 256, 0, PI, 1.0, false)
	$"Wheel/BarTree3".position.z = 깊이/2
	$"Wheel/BarTree3".rotation.x = PI/2

	$화살표.set_size(반지름/5,깊이/2, 깊이*1.5,0.5)

	var n :int = $Wheel.cell_count얻기()
	$"Wheel/원판".mesh.radial_segments = n

	선택rad바꾸기(PI/2)
	return self

func 선택rad바꾸기(rad :float) -> void:
	선택rad = rad
	$화살표.rotation = Vector3(0, 0, rad)
	$화살표.position = Vector3(sin(PI-rad) *반지름*1.1, cos(PI-rad) *반지름*1.1, 0 )

func 색설정하기(원판색 :Color, 장식색 :Color, 화살표색 :Color) -> void:
	$"Wheel/원판".mesh.material.albedo_color = 원판색
	$"Wheel/ValveHandle".색바꾸기(장식색)
	$"화살표".set_color(화살표색)
	$"Wheel/BarTree2".init_with_color(장식색, 원판색)
	$"Wheel/BarTree3".init_with_color(장식색.inverted(), 원판색.inverted())
	var n :int = $Wheel.cell_count얻기()
	$"Wheel/BarTree2".set_visible_bar_count(n)
	$"Wheel/BarTree3".set_visible_bar_count(n)

var rotation_per_second :float
var acceleration := 0.3 # per second
func 돌리기(dur_sec :float = 1.0) -> void:
	$"Wheel".rotation.z += rotation_per_second * 2 * PI * dur_sec
	if acceleration > 0:
		rotation_per_second *= pow( acceleration , dur_sec)
	if 회전중인가 and abs(rotation_per_second) <= 0.001:
		회전중인가 = false
		rotation_per_second = 0.0
		rotation_stopped.emit(id)
	$"Wheel/BarTree2".bar_rotation = -rotation_per_second/10
	$"Wheel/BarTree3".bar_rotation = -rotation_per_second/10


# spd : 초당 회전수
func 돌리기시작(spd :float) -> void:
	rotation_per_second = spd
	회전중인가 = true
	$"Wheel/BarTree2".auto_rotate_bar = true
	$"Wheel/BarTree2".bar_rotation = -spd/10
	$"Wheel/BarTree3".auto_rotate_bar = true
	$"Wheel/BarTree3".bar_rotation = -spd/10

func 멈추기시작(accel :float=0.5) -> void:
	assert(accel < 1.0)
	acceleration = accel

func 선택된cell강조상태켜기() -> void:
	var 선택칸 = 선택된cell얻기()
	if 선택칸 != null:
		선택칸.강조상태켜기()

func 선택된cell얻기() -> RouletteCell:
	return $Wheel.각도로cell얻기($"Wheel".rotation.z - 선택rad)
