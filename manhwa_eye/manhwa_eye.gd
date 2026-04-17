extends Node3D
class_name ManhwaEye

## face y+ , use rotate_x for face z

var animation := SimpleAnimation.new()

var Inner_radius :float :
	set(value):
		$Inner.mesh.radius = value

## rate to Outer radius
func add_Inner_move_animation(x_rate :float, y_rate :float, ani_dur :float):
	var new_pos := Vector3(get_Inner_move_range() * x_rate, 0 , get_Inner_move_range() * y_rate)
	animation.start_move("ani_move", $Inner, $Inner.position, new_pos, ani_dur)

## rate to Outer radius
func add_Inner_scale_animation(rate :float, ani_dur :float):
	var new_radius := get_Outer_radius() * rate
	SimpleAnimation.MakeAnimation("ani_scale", $Inner, "Inner_radius", $Inner.mesh.radius,  new_radius, ani_dur)

func set_radius(Outer_radius :float, Inner_radius_rate :float = 0.6) -> void:
	$Outer.mesh.radius = Outer_radius
	$Outer.mesh.height = Outer_radius * 0.4
	$Inner.mesh.radius = Outer_radius * Inner_radius_rate
	$Inner.mesh.height = Outer_radius * 0.4

func set_color(Outer_color :Color, Inner_color :Color) -> void:
	$Outer.mesh.material.albedo_color = Outer_color
	$Inner.mesh.material.albedo_color = Inner_color

func get_Inner_radius() -> float:
	return $Inner.mesh.radius

func get_Outer_radius() -> float:
	return $Outer.mesh.radius

func get_Inner_color() -> Color:
	return $Inner.mesh.material.albedo_color

func get_Outer_color() -> Color:
	return $Outer.mesh.material.albedo_color

func get_Inner() -> MultiMeshInstance3D:
	return $Inner

func get_Outer() -> MultiMeshInstance3D:
	return $Outer

## for move Inner in Outer boundary
func get_Inner_move_range() -> float:
	return get_Outer_radius() - get_Inner_radius()

## x_rate, y_rate : -1 ~ 1
func move_Inner(x_rate :float, y_rate :float) -> void:
	$Inner.position.x = get_Inner_move_range() * x_rate
	$Inner.position.z = get_Inner_move_range() * y_rate
