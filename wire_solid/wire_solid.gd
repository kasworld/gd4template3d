extends Node3D
class_name WireSolid

const FaceEdgeData = {
	4 :  [ [0, 3] ],
	6 :  [ [0, 3], [3, 7] ],
	8 :  [ [0, 4], [0, 5] ],
	20 : [ [0, 5], [5, 10] ],
	12 : [ [0, 3,], [3, 9,], [9, 18] ],
}

func init(face :int, edge_from:int, edge_to :int, outer_radius :float, wire_width :float, wire_color :Color, ball_radius :float) -> WireSolid:
	var points := PlatonicSolids.ScalePointList( PlatonicSolids.PointEdge[face][0], outer_radius )
	var lines := PlatonicSolids.PointListToLineList2(points, edge_from, edge_to )
	$Wires.multi_line_by_pos(lines, wire_width, wire_color)

	var sp_mesh := SphereMesh.new()
	sp_mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial(false)
	sp_mesh.material.metallic = 1.0
	sp_mesh.material.clearcoat_enabled = true
	sp_mesh.material.refraction_enabled = true
	sp_mesh.material.rim_enabled = true
	sp_mesh.radius = ball_radius
	sp_mesh.height = ball_radius *2
	$Spheres.init_meshs_by_point_list(sp_mesh, points, wire_color)

	outer_radius += wire_width
	$OuterSphere.mesh.radius = outer_radius
	$OuterSphere.mesh.height = outer_radius*2
	return self

func set_color(co :Color) -> WireSolid:
	$Wires.set_color_all(co)
	$OuterSphere.set_color_all(co)
	return self

func show_points(b :bool) -> void:
	$Spheres.visible = b
