extends Node3D
class_name GlassCabinet

func init(box_size :Vector3) -> GlassCabinet:
	$WallBox.mesh.size = box_size
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, 	Vector3(0, 0, box_size.z*2), box_size.length()*2)
	$AxisArrow3D.set_size(box_size.length()/10).set_colors()
	$Label3D.pixel_size = box_size.y/200
	$Label3D.position = Vector3(0,-box_size.y/2,box_size.z/2)
	return self

func show_axis_arrow(b :bool = true) -> GlassCabinet:
	$AxisArrow3D.visible = b
	return self

func show_wall_box(b :bool = true) -> GlassCabinet:
	$WallBox.visible = b
	return self
func set_box_color(co :Color) -> GlassCabinet:
	$WallBox.mesh.material.albedo_color = co
	return self

func show_label(b :bool = true) -> GlassCabinet:
	$Label3D.visible = b
	return self
func set_label_text(t :String) -> GlassCabinet:
	$Label3D.text = t
	return self
func set_label_pixel_size(sz :float) -> GlassCabinet:
	$Label3D.pixel_size = sz
	return self

func get_camera_light() -> MovingCameraLight:
	return $FixedCameraLight

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)
