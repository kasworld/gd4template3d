extends Node3D
class_name Turbine

static func scale_cos(rate :float) -> float:
	return (cos(rate*PI*2)+3)/4

func init_sample(count :int, radius :float, ring_width :float, arm_count :int, co1 :Color, co2 :Color) -> Turbine:
	init_basic(count, radius, ring_width, arm_count)
	set_transform_all(scale_cos)
	set_color_all(co1,co2)
	return self

func init_basic(count :int, radius :float, ring_width :float, arm_count :int) -> Turbine:
	_init_rings($RingsOut, count, radius, ring_width, false)
	_init_rings($RingsIn, count, radius, ring_width, true)
	var blade_mesh := BoxMesh.new()
	blade_mesh.size = Vector3(radius, ring_width/10, ring_width )
	$Blades.init_with_alpha(blade_mesh, count*arm_count, 1.0 ,false)
	return self

func _init_rings(rings :MultiMeshShape, count :int, radius :float, ring_width :float, flip_faces :bool) -> void:
	var ring_mesh := CylinderMesh.new()
	ring_mesh.cap_bottom = false
	ring_mesh.cap_top = false
	ring_mesh.top_radius = radius
	ring_mesh.bottom_radius = radius
	ring_mesh.height = ring_width
	ring_mesh.flip_faces = flip_faces
	rings.init_with_alpha(ring_mesh, count, 0.9, false)


func set_transform_all(scale_fn:Callable) -> Turbine:
	var count :int = $RingsOut.multimesh.visible_instance_count
	var arm_count :int = $Blades.multimesh.visible_instance_count / count
	var mesh_size :Vector3 = $Blades.multimesh.mesh.size
	var ring_width := mesh_size.z
	var radius := mesh_size.x
	for i in count:
		var rate := float(i)/float(count-1)
		var r_scale :float = scale_fn.call(rate)
		var scaled_size := Vector3(r_scale,r_scale,1)
		var ring_pos := Vector3(0,0,-count*ring_width/2 + i*ring_width)

		var t = Transform3D(Basis(), ring_pos)
		t = t.scaled_local(scaled_size)
		t = t.rotated_local(Vector3.RIGHT, PI/2)
		$RingsOut.multimesh.set_instance_transform(i, t)
		$RingsIn.multimesh.set_instance_transform(i, t)

		var cell각도 := 2.0*PI / arm_count
		var base_int := i*arm_count
		var blade_rot_rad := rate * PI
		var blade_radius := radius*r_scale/2
		for j in arm_count:
			var rad := cell각도 *j + blade_rot_rad
			t = Transform3D(Basis(), Vector3(cos(rad) *blade_radius,sin(rad) *blade_radius, ring_pos.z))
			t = t.scaled_local(scaled_size)
			t = t.rotated_local(Vector3.BACK, rad)
			t = t.rotated_local(Vector3.LEFT, PI/10)
			$Blades.multimesh.set_instance_transform(base_int+j, t)
	return self

func set_color_all(co1 :Color, co2 :Color) -> Turbine:
	var count :int = $RingsOut.multimesh.visible_instance_count
	var arm_count :int = $Blades.multimesh.visible_instance_count / count
	for i in count:
		var rate := float(i)/float(count-1)
		var co := co1.lerp(co2, rate)
		$RingsOut.multimesh.set_instance_color(i,co)
		$RingsIn.multimesh.set_instance_color(i,co)
		var base_int := i*arm_count
		for j in arm_count:
			$Blades.multimesh.set_instance_color(base_int+j, co)
	return self

func set_inst_color(i:int, co :Color) -> void:
	var count :int = $RingsOut.multimesh.visible_instance_count
	var arm_count :int = $Blades.multimesh.visible_instance_count / count
	$RingsOut.multimesh.set_instance_color(i,co)
	$RingsIn.multimesh.set_instance_color(i,co)
	var base_int := i*arm_count
	for j in arm_count:
		$Blades.multimesh.set_instance_color(base_int+j, co)
