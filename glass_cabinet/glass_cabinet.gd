extends Node3D
class_name GlassCabinet

func init(box_size :Vector3) -> GlassCabinet:
	$WallBox.mesh.size = box_size
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, 	Vector3(0, 0, box_size.z*2), box_size.length()*2)
	$AxisArrow3D.set_size(box_size.length()/10).set_colors()
	return self

func set_box_color(co :Color) -> GlassCabinet:
	$WallBox.mesh.material.albedo_color = co
	return self
