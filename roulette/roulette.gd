extends Node3D
class_name Roulette

signal rotation_stopped(rl :Roulette)

var id :int
var 반지름 :float
var 깊이 :float
const 선시작비 := 0.5
const 선끝비 := 1.0

func get_wheel() -> RouletteWheel:
	return $Wheel

func show_back(b :bool) -> void:
	$"Wheel/원판".visible = b

func show_velvehandle(b :bool) -> void:
	$Wheel/ValveHandle.visible = b

func show_bartree(b :bool) -> void:
	$Wheel/BarTree2.visible = b
	$Wheel/BarTree1.visible = b

func show_spliters(b :bool) -> void:
	$Wheel/Spliters.visible = b

func show_arrow(b :bool) -> void:
	$"화살표".visible = b

func show_label(b :bool) -> void:
	$IDLabel.visible = b

func set_spliters_color(co :Color) -> void:
	$Wheel/Spliters.set_color_all(co)

func set_back_color(co :Color) -> void:
	$"Wheel/원판".mesh.material.albedo_color = co

func set_velvehandle_color(co :Color) -> void:
	$"Wheel/ValveHandle".색바꾸기(co)

func set_arrow_color(co :Color) -> void:
	$"화살표".set_color(co)

func set_bartree_color(co1 :Color, co2 :Color) -> void:
	$"Wheel/BarTree2".set_gradient_color_all(co1, co2)
	$"Wheel/BarTree1".set_gradient_color_all(co1.inverted(), co2.inverted())

func set_all_text_color(co :Color) -> void:
	$Wheel.set_all_text_color(co)

func 색설정하기(원판색 :Color, 장식색 :Color, 화살표색 :Color) -> void:
	$"Wheel/원판".mesh.material.albedo_color = 원판색
	$"Wheel/ValveHandle".색바꾸기(장식색)
	$"화살표".set_color(화살표색)
	$"Wheel/BarTree2".set_gradient_color_all(장식색, 원판색)
	$"Wheel/BarTree1".set_gradient_color_all(장식색.inverted(), 원판색.inverted())
	var count :int = $Wheel.cell_count얻기()
	$"Wheel/BarTree2".set_visible_count(count)
	$"Wheel/BarTree1".set_visible_count(count)

func init(ida :int, 반지름a :float, 깊이a :float, color_text_info_list :Array ) -> Roulette:
	id = ida
	반지름 = 반지름a
	깊이 = 깊이a

	$Wheel.init(반지름, 깊이, color_text_info_list)
	$Wheel.rotation_stopped.connect(결과가결정됨)

	$Wheel/Spliters.init_집중선(반지름, 선시작비, 선끝비, 깊이, color_text_info_list.size(), Color.WHITE )

	# for debug
	$IDLabel.text = "%s" % id
	$IDLabel.outline_size = 반지름/20
	$IDLabel.pixel_size = 반지름/100

	$"Wheel/ValveHandle".init(반지름*0.1, 반지름*0.1, 4, Color.WHITE)
	$"Wheel/ValveHandle".rotation.x = PI/2

	var count := color_text_info_list.size()
	var tree_size := Vector3(반지름, 깊이, 반지름*0.05)
	$"Wheel/BarTree2".init_bartree_with_color(Color.BLACK, Color.WHITE, count).init_bartree_transform(tree_size, 0)
	$"Wheel/BarTree2".position.z = 깊이/2
	$"Wheel/BarTree2".rotation.x = PI/2

	$"Wheel/BarTree1".init_bartree_with_color(Color.BLACK, Color.WHITE, count).init_bartree_transform(tree_size, 0)
	$"Wheel/BarTree1".position.z = 깊이/2
	$"Wheel/BarTree1".rotation.x = PI/2
	$"Wheel/BarTree1".rotate(Vector3.FORWARD, PI/2)

	$"Wheel/원판".mesh.height = 깊이
	$"Wheel/원판".mesh.bottom_radius = 반지름
	$"Wheel/원판".mesh.top_radius = 반지름
	$"Wheel/원판".position.z = -깊이
	var n :int = $Wheel.cell_count얻기()
	$"Wheel/원판".mesh.radial_segments = n
	$"Wheel/원판".rotation.x = PI/2
	$"Wheel/원판".rotate(Vector3.FORWARD, PI/n)

	$화살표.set_size(반지름/5, 깊이*0.25, 깊이*0.5, 0.5)
	$화살표.rotation = Vector3(0, 0, PI/2)
	$화살표.position = Vector3(sin(PI/2) *반지름*1.1, cos(PI/2) *반지름*1.1, 0 )
	return self

func 결과가결정됨(_rl :RouletteWheel) -> void:
	rotation_stopped.emit(self)

func 회전중인가() -> bool:
	return $Wheel.회전중인가


func 장식돌리기() -> void:
	bar_rot = -$"Wheel".rotation_per_second/10

## rps : 초당 회전수
func start_rotation(rps :float) -> void:
	$"Wheel".start_rotation(rps)
	bar_rot = -rps/10

## accel < 1.0
func set_acceleration(accel :float=0.5) -> void:
	$"Wheel".set_acceleration(accel)

var bar_rot := 0.1
func _process(_delta: float) -> void:
	$"Wheel/BarTree2".rotate_tree_bar_y(bar_rot)
	$"Wheel/BarTree1".rotate_tree_bar_y(bar_rot)


func 선택된cell강조상태켜기() -> void:
	var 선택칸 = 선택된cell얻기()
	if 선택칸 != null:
		선택칸.강조상태켜기()

func 선택된cell얻기() -> RouletteCell:
	return $Wheel.각도로cell얻기($"Wheel".rotation.z)
