extends Node3D
class_name ManhwaFace

## Sclera : 눈전체 - 희자위
## Iris : 홍채 - 검은자위
## Pupil : 동공


func get_left_eye() -> ManhwaEye:
	return $LeftEye

func get_right_eye() -> ManhwaEye:
	return $RightEye

func get_face() -> MeshInstance3D:
	return $Face

func show_face(b :bool) -> void:
	$Face.visible = b

func set_face_color(co :Color) -> void:
	$Face.mesh.material.albedo_color = co
	$Face/LeftEar.mesh.material.albedo_color = co
	$Face/RightEar.mesh.material.albedo_color = co
	$Face/LeftEar/Inner.mesh.material.albedo_color = co.darkened(0.2)
	$Face/RightEar/Inner.mesh.material.albedo_color = co.lightened(0.2)

func set_eye_color(Outer_color :Color, Inner_color :Color) -> void:
	$LeftEye.set_color(Outer_color,Inner_color)
	$RightEye.set_color(Outer_color,Inner_color)

func set_eye_scale(scale_outer :Vector3) ->void:
	$LeftEye.get_Sclera().scale = scale_outer
	$RightEye.get_Sclera().scale = scale_outer


enum EarType {Round, Bunny, Puppy}

const EarTypeToScale :Dictionary[EarType,Vector3] = {
	EarType.Round : Vector3(1.0, 1.0, 1.0),
	EarType.Bunny : Vector3(0.5, 1.0, 1.0),
	EarType.Puppy : Vector3(1.0, 1.0, 0.5),
}

var ear_type :EarType = EarType.Round
var ear_rad :float = PI/4
var ear_overlap_rate :float = 0.1

func set_ear_type(et :EarType) -> void:
	ear_type = et
	var ear_scale := EarTypeToScale[ear_type]
	$Face/LeftEar.scale = ear_scale
	$Face/RightEar.scale = ear_scale
	$Face/LeftEar/Inner.scale = ear_scale
	$Face/RightEar/Inner.scale = ear_scale

func set_ear_rad(rad :float, overlap :float = ear_overlap_rate) -> void:
	ear_rad = rad
	ear_overlap_rate = overlap
	var sq_len :float = $Face.mesh.radius + $Face/LeftEar.mesh.radius * $Face/LeftEar.scale.z
	sq_len *= (1-ear_overlap_rate)
	$Face/LeftEar.position = Vector3( sin(rad), 0, cos(rad) ) * sq_len
	$Face/LeftEar.rotation.y = rad
	$Face/RightEar.position = Vector3( -sin(rad), 0, cos(rad) ) * sq_len
	$Face/RightEar.rotation.y = -rad

func set_ear_radius(r :float) -> void:
	var ear_radius := r
	var ear_height := r/2.5
	$Face/LeftEar.mesh.radius = ear_radius
	$Face/LeftEar.mesh.height = ear_height
	$Face/LeftEar.mesh.rings = 4
	$Face/LeftEar/Inner.mesh.radius = ear_radius * 0.8
	$Face/LeftEar/Inner.mesh.height = ear_height
	$Face/LeftEar/Inner.mesh.rings = 4
	$Face/RightEar.mesh.radius = ear_radius
	$Face/RightEar.mesh.height = ear_height
	$Face/RightEar.mesh.rings = 4
	$Face/RightEar/Inner.mesh.radius = ear_radius * 0.8
	$Face/RightEar/Inner.mesh.height = ear_height
	$Face/RightEar/Inner.mesh.rings = 4
	set_ear_rad(ear_rad, ear_overlap_rate)

func set_radius(r :float) -> void:
	$Face.mesh.radius = r
	$Face.mesh.height = r/5
	set_ear_radius(r/2)

	$LeftEye.set_radius(r/2)
	$LeftEye.position.x = -r/2
	$RightEye.set_radius(r/2)
	$RightEye.position.x = r/2

func move_eye_Inner(x_rate :float, y_rate :float) -> void:
	$LeftEye.move_Iris(x_rate,y_rate)
	$RightEye.move_Iris(x_rate,y_rate)

func set_eye_Inner_radius_rate(rate :float) -> void:
	$LeftEye.set_Iris_radius_rate(rate)
	$RightEye.set_Iris_radius_rate(rate)

## rotate inner node3d
func rotation_axis(axis :int, rad :float = PI/2) -> void:
	$Face.rotation[axis] = rad
	$LeftEye.rotation[axis] = rad
	$RightEye.rotation[axis] = rad
