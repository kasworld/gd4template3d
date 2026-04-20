extends Node3D
class_name ManhwaFace

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

func set_eye_color(Outer_color :Color, Inner_color :Color) -> void:
	$LeftEye.set_color(Outer_color,Inner_color)
	$RightEye.set_color(Outer_color,Inner_color)

func set_eye_scale(scale_outer :Vector3) ->void:
	$LeftEye.get_Outer().scale = scale_outer
	$RightEye.get_Outer().scale = scale_outer


func set_radius(r :float) -> void:
	$Face.mesh.radius = r
	$Face.mesh.height = r/5
	$Face/LeftEar.mesh.radius = r/2
	$Face/LeftEar.mesh.height = r/5
	$Face/RightEar.mesh.radius = r/2
	$Face/RightEar.mesh.height = r/5
	var sq_len := sqrt(2)/2*(r+r/2)
	$Face/LeftEar.position = Vector3( -sq_len, 0, sq_len )
	$Face/RightEar.position = Vector3( sq_len,0, sq_len )

	$LeftEye.set_radius(r/2)
	$LeftEye.position.x = -r/2
	$RightEye.set_radius(r/2)
	$RightEye.position.x = r/2

func move_Inner(x_rate :float, y_rate :float) -> void:
	$LeftEye.move_Inner(x_rate,y_rate)
	$RightEye.move_Inner(x_rate,y_rate)

func set_Inner_radius_rate(rate :float) -> void:
	$LeftEye.set_Inner_radius_rate(rate)
	$RightEye.set_Inner_radius_rate(rate)
