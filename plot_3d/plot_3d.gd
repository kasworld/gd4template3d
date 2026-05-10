extends MultiMeshShape
class_name Plot3D

var calc_grid :CalcGrid3D

## posi to instance index
var plotted :Dictionary[Vector3i,int] = {}

func init_plot3d(aabb: AABB, cell_count :Vector3i, cell_scale :float = 1.0, transparent :bool = false) -> Plot3D:
	calc_grid = CalcGrid3D.new(aabb, cell_count)
	var mesh := BoxMesh.new()
	mesh.size = calc_grid.unit_size * cell_scale
	mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial(transparent)
	init_with_color_mesh(mesh, calc_grid.get_grid_count(), false)
	set_visible_count(0)
	#for i in calc_grid.get_grid_count():
		#var pos := calc_grid.get_n_th_lanepos(i)
		#var t := Transform3D(Basis(), pos)
		#multimesh.set_instance_transform(i,t)
		#multimesh.set_instance_color(i, RandomColor.random_color())
	return self

func plot_at(posi :Vector3i, co :Color) -> void:
	var pos := calc_grid.posi_to_lanepos(posi)
	var index := plotted.size()
	if plotted.has(posi):
		index -= 1
	plotted[posi] = index
	var t := Transform3D(Basis(), pos)
	multimesh.set_instance_transform(index,t)
	multimesh.set_instance_color(index, co)
	set_visible_count(plotted.size())
