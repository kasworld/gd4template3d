extends MultiMeshShape
class_name TileGrid

## for animation
var tile_rotation_x :float:
	set(rad):
		for i in calc_grid.get_grid_count():
			set_inst_rotation(i, Vector3.RIGHT, rad)

var tile_rotation_y :float:
	set(rad):
		for i in calc_grid.get_grid_count():
			set_inst_rotation(i, Vector3.UP, rad)

var tile_rotation_z :float:
	set(rad):
		for i in calc_grid.get_grid_count():
			set_inst_rotation(i, Vector3.FORWARD, rad)

var calc_grid :CalcGrid3D
var pos_list :Array
var animation :SimpleAnimation

func init(sz :Vector3, grid_count :Vector2i, gap_rate :float, co :Color) -> MultiMeshShape:
	calc_grid = CalcGrid3D.new(
		CalcGrid3D.SizeToAABB(sz),
		CalcGrid3D.xy_Vector2iToVector3i(grid_count,1),
	)
	pos_list = []
	for i in calc_grid.get_grid_count():
		pos_list.append(calc_grid.get_n_th_lanepos(i))
	var mesh := BoxMesh.new()
	mesh.size = calc_grid.unit_size *gap_rate
	mesh.material = make_color_material()
	init_meshs_by_point_list(mesh, pos_list , co)
	animation = SimpleAnimation.new()
	animation.animation_ended.connect(animation_ended)

	return self

func animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	pass

func _process(_delta: float) -> void:
	animation.handle_animation()

func start_tile_rotate(axis :int, from :float, to :float, dur_sec :float) -> void:
	animation.add_animation(SimpleAnimation.MakeAnimation(
		"", self,
		["tile_rotation_x", "tile_rotation_y", "tile_rotation_z"][axis],
		from , to, dur_sec
	))

func start_tile_rotate_x(from :float, to :float, dur_sec :float) -> void:
	animation.add_animation(SimpleAnimation.MakeAnimation(
		"", self, "tile_rotation_x", from , to, dur_sec
	))

func start_tile_rotate_y(from :float, to :float, dur_sec :float) -> void:
	animation.add_animation(SimpleAnimation.MakeAnimation(
		"", self, "tile_rotation_y", from , to, dur_sec
	))

func start_tile_rotate_z(from :float, to :float, dur_sec :float) -> void:
	animation.add_animation(SimpleAnimation.MakeAnimation(
		"", self, "tile_rotation_z", from , to, dur_sec
	))
