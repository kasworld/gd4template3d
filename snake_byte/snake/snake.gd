extends SBObj
class_name SBSnake

signal snake_dead()
signal eat_apple(pos :Vector2i)
signal tail_enter()
signal reach_goal()

var field :PlacedThings
var astar_grid :AStarGrid2D

var pos2d_list :Array[Vector2i]
var move_dir :Dir8Lib.Dir
var dest_body_len :int
var is_alive : bool
var cmd_queue :Array

func _to_string() -> String:
	return "SBSnake alive:%s movedir:%s %s" % [is_alive,move_dir,pos2d_list]

func init(field_a :PlacedThings, astar_grid_a :AStarGrid2D) -> SBSnake:
	field = field_a
	astar_grid = astar_grid_a

	var mesh := SphereMesh.new()
	mesh.radius = SnakeByte.tile_size.x /2
	mesh.height = SnakeByte.tile_size.y
	mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial()
	var pos := SnakeByte.calc_grid.posi_to_lanepos( Vector3i(SBWalls.FieldSize.x/2,SBWalls.FieldSize.y, 0))
	$Body.init_with_color_mesh(mesh, SBWalls.FieldSize.x*SBWalls.FieldSize.y/2, 1.0,  pos)
	dest_body_len = SnakeByte.SnakeLenStart
	pos2d_list.append(SBWalls.StartPos)
	is_alive = true
	cmd_queue = []
	return self

func process_frame() -> void:
	if not is_alive:
		return
	if cmd_queue.size() >= 1:
		var dir :Dir8Lib.Dir = cmd_queue.pop_back()
		change_move_dir(dir)
		cmd_queue.clear()
	if pos2d_list.size() >= dest_body_len:
		var tailpos :Vector2i = pos2d_list.pop_back()
		var old = field.get_at(tailpos)
		if old is not SBStart:
			field.del_at(tailpos)
			assert( old is SBSnake, "invalid tailpos %s %s" %[tailpos, old] )
			astar_grid.set_point_solid(tailpos, false)
		else :
			tail_enter.emit()
	var headpos := get_next_head_pos()
	var headthings = field.get_at(headpos)
	if headthings is SBApple:
		dest_body_len += SnakeByte.SankeLenInc
		eat_apple.emit(headpos)
	elif headthings is SBGoal:
		reach_goal.emit()
		return
	elif headthings != null:
		snake_dead.emit()
		is_alive = false
		return
	pos2d_list.push_front(headpos)
	field.set_at(headpos, self)
	astar_grid.set_point_solid(headpos)
	$Body.set_visible_count(pos2d_list.size())
	for i in pos2d_list.size():
		$Body.set_inst_position(i, SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.xy_Vector2iToVector3i(pos2d_list[i], 0)) )
	$Body.set_gradient_color_all(Color.RED, Color.BLUE)

func get_next_head_pos() -> Vector2i:
	return pos2d_list[0] + Dir8Lib.Dir2Vt[move_dir]

func change_move_dir(dir :Dir8Lib.Dir) -> void:
	assert(not Dir8Lib.IsDiagonal(dir), "invalid dir %s" %[dir])
	if Dir8Lib.DirOpposite(dir) == move_dir:
		print_debug("cannot change dir %s %s" % [dir, move_dir])
		return
	move_dir = dir

var key2dir = {
	KEY_UP:Dir8Lib.Dir.North,
	KEY_DOWN:Dir8Lib.Dir.South,
	KEY_LEFT:Dir8Lib.Dir.West,
	KEY_RIGHT:Dir8Lib.Dir.East,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var dir = key2dir.get(event.keycode)
		if dir != null:
			cmd_queue.append(dir)
