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

func set_radius(r :float) -> void:
	$Face.mesh.radius = r
	$Face.mesh.height = r/5
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
