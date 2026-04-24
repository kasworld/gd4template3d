extends Node3D
class_name ManhwaEye

## Sclera : 눈전체 - 희자위
## Iris : 홍채 - 검은자위
## Pupil : 동공
## face y+ , use rotate_x for face z

func get_Sclera() -> MeshInstance3D:
	return $Sclera
func get_Iris() -> MeshInstance3D:
	return $Iris
func get_Pupil() -> MeshInstance3D:
	return $Pupil

func get_Sclera_radius() -> float:
	return $Sclera.mesh.radius
func get_Iris_radius() -> float:
	return $Iris.mesh.radius
func get_Pupil_radius() -> float:
	return $Pupil.mesh.radius

func get_Sclera_color() -> Color:
	return $Sclera.mesh.material.albedo_color
func get_Iris_color() -> Color:
	return $Iris.mesh.material.albedo_color
func get_Pupil_color() -> Color:
	return $Pupil.mesh.material.albedo_color

## for animation
var Iris_radius_rate :float :
	set(rate):
		set_Iris_radius_rate(rate)

## for animation
var Iris_position :Vector3 :
	set(value):
		$Iris.position = value
		$Pupil.position = value

## rate (-1.0 ~ 1.0) to Sclera boundary
func make_Iris_move_animation(x_rate :float, y_rate :float, ani_dur :float) -> Dictionary:
	var new_pos := Vector3(get_Iris_move_range() * x_rate, 0 , get_Iris_move_range() * y_rate)
	return SimpleAnimation.MakeAnimation( "ani_move", self, "Iris_position", $Iris.position, new_pos, ani_dur)

## rate (0 ~ 1.0) to Sclera radius
func make_Iris_scale_animation(rate :float, ani_dur :float) -> Dictionary:
	var current_rate :float = $Iris.mesh.radius / $Sclera.mesh.radius
	return SimpleAnimation.MakeAnimation("ani_scale", self, "Iris_radius_rate", current_rate, rate, ani_dur)

func set_radius(Sclera_radius :float, Iris_rate :float = 0.6) -> void:
	$Sclera.mesh.radius = Sclera_radius
	$Sclera.mesh.height = Sclera_radius * 0.4
	set_Iris_radius_rate(Iris_rate)

func set_color(Sclera_color :Color, Iris_color :Color) -> void:
	$Sclera.mesh.material.albedo_color = Sclera_color
	$Iris.mesh.material.albedo_color = Iris_color
	$Pupil.mesh.material.albedo_color = Iris_color.darkened(0.5)

## for move Iris in Sclera boundary
func get_Iris_move_range() -> float:
	return get_Sclera_radius() - get_Iris_radius()

## x_rate, y_rate : -1 ~ 1
func move_Iris(x_rate :float, y_rate :float) -> void:
	$Iris.position.x = get_Iris_move_range() * x_rate
	$Iris.position.z = get_Iris_move_range() * y_rate
	$Pupil.position = $Iris.position
	$Pupil.position.y = $Iris.position.y - $Iris.mesh.height/2

func set_Iris_radius_rate(rate :float) -> void:
	$Iris.mesh.radius = get_Sclera_radius() * rate
	$Iris.mesh.height = $Sclera.mesh.height
	$Pupil.mesh.radius = $Iris.mesh.radius /2
	$Pupil.mesh.height = $Iris.mesh.height /2
