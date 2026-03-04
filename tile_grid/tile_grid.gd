extends MultiMeshShape
class_name TileGrid

func init(sz :Vector3, grid_count :Vector2i, gap_rate :float, co :Color) -> MultiMeshShape:
	var calc_grid := CalcGrid3D.new(
		CalcGrid3D.SizeToAABB(sz),
		CalcGrid3D.xy_Vector2iToVector3i(grid_count,1),
	)
	var plist := []
	for i in calc_grid.get_grid_count():
		plist.append(calc_grid.get_n_th_lanepos(i))
	var mesh := BoxMesh.new()
	mesh.size = calc_grid.unit_size *gap_rate
	mesh.material = make_color_material()
	init_meshs_by_point_list(mesh, plist , co)
	return self
