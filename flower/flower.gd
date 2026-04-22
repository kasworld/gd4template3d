extends Node3D
class_name Flower

func make_petal_mesh(radius :float) -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius/5
	mesh.is_hemisphere = true
	mesh.flip_faces = true
	mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial(true)
	return mesh


func set_center(radius :float, co :Color) -> void:
	$Center.mesh.radius = radius
	$Center.mesh.material.albedo_color = co

func init(radius :float, count :int, center_rate :float, overlap_rate :float, co_center :Color, co_petal :Color) -> Flower:
	var center_radius := radius * center_rate
	var petal_radius := (radius - center_radius)/2
	set_center(center_radius, co_center)
	$Petal.init_with_color_mesh(
		make_petal_mesh(petal_radius),
		count, false,
		)
	var unit_rad := 2.0*PI/count
	for i in count:
		transform_petal(i, radius - petal_radius*(1+overlap_rate), i*unit_rad)
		$Petal.multimesh.set_instance_color(i,co_petal)
	return self

func transform_petal(index :int, radius :float, rad :float) -> void:
	var scale_petal := Vector3(0.5, 1.0, 1.0)
	var pos := Vector3(sin(rad), 0, cos(rad)) * radius
	var t := Transform3D(Basis(), pos)
	t = t.rotated_local(Vector3.UP, rad)
	t = t.scaled_local(scale_petal)
	$Petal.multimesh.set_instance_transform(index,t)
