extends Node3D
class_name Turbine

func init(count :int, radius :float, ring_width :float, arm_count :int, co1 :Color, co2 :Color) -> Turbine:
	var blades :MultiMeshShape = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate()
	var rings_out:= make_rings(count,radius,ring_width, false)
	var rings_in:= make_rings(count,radius,ring_width, true)
	var blade_mesh := BoxMesh.new()
	blade_mesh.size = Vector3(radius, ring_width/10, ring_width )
	blades.init_with_alpha(blade_mesh, count*arm_count)
	add_child(blades)
	for i in count:
		var rate := float(i)/float(count-1)
		var r_scale := (cos(rate*PI*2)+3)/4
		var scaled_size := Vector3(r_scale,r_scale,1)
		var co := co1.lerp(co2, rate)
		var ring_pos := Vector3(0,0,-count*ring_width/2 + i*ring_width)
		rings_out.set_inst_scale(i, scaled_size)
		rings_out.set_inst_position(i,ring_pos)
		rings_out.set_inst_rotation(i, Vector3.RIGHT, PI/2)
		rings_out.set_inst_color(i,co)
		rings_in.set_inst_scale(i, scaled_size)
		rings_in.set_inst_position(i,ring_pos)
		rings_in.set_inst_rotation(i, Vector3.RIGHT, PI/2)
		rings_in.set_inst_color(i,co)

		var cell각도 := 2.0*PI / arm_count
		var base_int := i*arm_count
		var blade_rot_rad := rate * PI
		for j in arm_count:
			var rad := cell각도 *j + blade_rot_rad
			blades.set_inst_rotation(base_int+j, Vector3.BACK, rad)
			blades.set_inst_rotation(base_int+j, Vector3.LEFT, PI/10)
			blades.set_inst_position(base_int+j, Vector3(cos(rad) *radius*r_scale/2,sin(rad) *radius*r_scale/2, ring_pos.z) )
			blades.set_inst_color(base_int+j, co)
			blades.set_inst_scale(base_int+j, scaled_size)
	return self

func make_rings(count :int, radius :float, ring_width :float, flip_faces :bool) -> MultiMeshShape:
	var rings :MultiMeshShape = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.cap_bottom = false
	ring_mesh.cap_top = false
	ring_mesh.top_radius = radius
	ring_mesh.bottom_radius = radius
	ring_mesh.height = ring_width
	ring_mesh.flip_faces = flip_faces
	rings.init_with_alpha(ring_mesh, count,0.9)
	add_child(rings)
	return rings
