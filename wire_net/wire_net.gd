extends Node3D
class_name WireNet

func init(net_size :Vector2, grid_count :Vector2i, wire_width :float, wire_height :float, co :Color, alpha :float = 1.0) -> WireNet:
	init_wire_H(net_size,grid_count,wire_width,wire_height,co,alpha)
	init_wire_V(net_size,grid_count,wire_width,wire_height,co,alpha)
	return self

func init_wire_H(net_size :Vector2, grid_count :Vector2i, wire_width :float, wire_height :float, co :Color, alpha :float = 1.0) -> WireNet:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(net_size.x, wire_width, wire_height)
	mesh.material = MultiMeshShape.make_color_material(alpha)
	$WireH.init_with_color_mesh(mesh, grid_count.y)
	var pos_shift := -Vector3(net_size.x, net_size.y, 0)/2
	for i in grid_count.y:
		var pos := Vector3(net_size.x/2, net_size.y/(grid_count.y-1)* i, 0) + pos_shift
		var t := Transform3D(Basis(), pos)
		$WireH.multimesh.set_instance_transform(i,t)
	set_color_H(co)
	return self

func set_color_H(co :Color) -> void:
	$WireH.set_color_all(co)

func set_color_V(co :Color) -> void:
	$WireV.set_color_all(co)

func init_wire_V(net_size :Vector2, grid_count :Vector2i, wire_width :float, wire_height :float, co :Color, alpha :float = 1.0) -> WireNet:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(wire_width, net_size.x, wire_height)
	mesh.material = MultiMeshShape.make_color_material(alpha)
	$WireH.init_with_color_mesh(mesh, grid_count.x)
	var pos_shift := -Vector3(net_size.x, net_size.y, 0)/2
	for i in grid_count.x:
		var pos := Vector3( net_size.x/(grid_count.x-1)* i, net_size.y/2, 0) + pos_shift
		var t := Transform3D(Basis(), pos)
		$WireH.multimesh.set_instance_transform(i,t)
	return self
