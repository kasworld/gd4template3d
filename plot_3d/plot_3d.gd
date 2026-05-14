extends MultiMeshShape
class_name Plot3D

var calc_grid :CalcGrid3D

## posi to instance index
var plotted :Dictionary[Vector3i,int] = {}

func clear() -> void:
	set_visible_count(0)
	plotted.clear()

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

## return success or fail
func del_at(posi :Vector3i) -> bool:
	if not plotted.has(posi):
		return false
	var todel_index := plotted[posi]
	plotted.erase(posi)
	set_visible_count(plotted.size())
	if plotted.size() == 0:
		return true
	var last_index := plotted.size()
	copy_instance(last_index, todel_index)
	return true

func copy_instance(from:int, to:int) -> void:
	var from_tr := multimesh.get_instance_transform(from)
	multimesh.set_instance_transform(to, from_tr)
	var from_co := multimesh.get_instance_color(from)
	multimesh.set_instance_color(to, from_co)

func draw_texture2d_face_z(posi :Vector3i, texture2d :Texture2D) -> void:
	var image := texture2d.get_image()
	if image.is_compressed():
		image.decompress()
	var image_size := image.get_size()
	for xi in image_size.x:
		for yi in image_size.y:
			var co :Color = image.get_pixel(xi,yi)
			plot_at(Vector3i(xi,image_size.y-yi-1,0) + posi ,co)
