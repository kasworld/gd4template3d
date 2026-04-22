extends Node3D
class_name Flower


#func make_petal_mesh_cylinder(radius :float, radial_segment :int = 64) -> Mesh:
	#var mesh := CylinderMesh.new()
	#mesh.bottom_radius = radius
	#mesh.top_radius = radius
	#mesh.height = radius/5
	#mesh.radial_segments = radial_segment
	##mesh.rings = 4
	##mesh.flip_faces = true
	#mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial(true)
	#return mesh

func make_petal_mesh_sphere(radius :float, radial_segment :int = 64) -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius/5
	mesh.is_hemisphere = true
	mesh.radial_segments = radial_segment
	mesh.rings = 4
	mesh.flip_faces = true
	mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial(true)
	return mesh

func transform_petal(index :int, radius :float, rad :float, petal_width_scale :float = 0.5) -> void:
	var scale_petal := Vector3(petal_width_scale, 1.0, 1.0)
	var pos := Vector3(sin(rad), 0, cos(rad)) * radius
	var t := Transform3D(Basis(), pos)
	t = t.rotated_local(Vector3.UP, rad)
	t = t.scaled_local(scale_petal)
	$Petal.multimesh.set_instance_transform(index,t)

func init_petal(flower_radius :float, petal_radius :float, count :int, co :Color, petal_width_scale :float = 0.5, petal_radial_segment :int = 64) -> Flower:
	$Petal.init_with_color_mesh(make_petal_mesh_sphere(petal_radius,petal_radial_segment), count, false)
	var unit_rad := 2.0*PI/count
	for i in count:
		transform_petal(i, flower_radius - petal_radius, i*unit_rad, petal_width_scale)
		$Petal.multimesh.set_instance_color(i,co)
	return self

func init_center(radius :float, co :Color, radial_segment :int = 64) -> Flower:
	$Center.mesh.radius = radius
	$Center.mesh.height = radius / 5
	$Center.mesh.radial_segments = radial_segment
	$Center.mesh.rings = 4
	$Center.mesh.material.albedo_color = co
	$Center.visible = true
	return self

## rotate inner node3d
func rotation_axis(axis :int, rad :float = PI/2) -> void:
	$Petal.rotation[axis] = rad
	$Center.rotation[axis] = -rad
