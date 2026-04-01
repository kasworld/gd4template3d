extends SBObj
class_name SBWalls

static var FieldSize := Vector2i(48,27)
static var StartPos := Vector2i(FieldSize.x/2, 0)
static var GoalPos := Vector2i(FieldSize.x/2, FieldSize.y-1)
static var BounderyWalls := [
	["hline", 0, FieldSize.x-2, 0],
	["vline", FieldSize.x-1, 0, FieldSize.y-2],
	["hline", 1, FieldSize.x-1, FieldSize.y-1],
	["vline", 0, 1, FieldSize.y-1],
]
static var StageWalls := [
	[],
	[
		["hline", FieldSize.x/2-5, FieldSize.x/2+5, FieldSize.y/2],
	],
	[
		["hline", 5, FieldSize.x/2-2, FieldSize.y/2],
		["hline", FieldSize.x/2+2, FieldSize.x-1-5, FieldSize.y/2],
		["vline", FieldSize.x/2, 5, FieldSize.y/2-2],
		["vline", FieldSize.x/2, FieldSize.y/2+2, FieldSize.y-1-5],
	],
]

var field :PlacedThings
var astar_grid :AStarGrid2D
var wall_list :Array # [ [Vector2i] ]
var startwall_index :int
var goalwall_index :int
var animate_inst :Dictionary

func init(stage_number :int, field_a :PlacedThings, astar_grid_a :AStarGrid2D) -> void:
	field = field_a
	astar_grid = astar_grid_a
	wall_list = []
	var mesh := BoxMesh.new()
	mesh.size = SnakeByte.tile_size *0.9
	mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial()
	$MultiMeshShape.multimesh.instance_count = 0
	$MultiMeshShape.init_with_color_mesh(mesh, SBWalls.FieldSize.x*SBWalls.FieldSize.y/2)
	exec_script(BounderyWalls)
	var wall_script :Array = StageWalls[stage_number % StageWalls.size()]
	exec_script(wall_script)
	wall_list_to_MMS()
	# stop old animation
	animate_inst = {
		"start_time" : 0,
		"inst_index" : 0,
		"ani_dur_sec" : 0,
		"pos1" :Vector3.ZERO,
		"pos2" :Vector3.ZERO,
	}

func wall_list_to_MMS() -> void:
	var inst_index := 0
	for l in wall_list:
		var co :Color = NamedColors.random_color()
		for pos in l:
			if pos == GoalPos:
				goalwall_index = inst_index
			if pos == StartPos:
				startwall_index = inst_index
				pos = pos + Dir8Lib.Dir2Vt[Dir8Lib.Dir.SouthEast]
			else:
				field.set_at(pos, self)
				astar_grid.set_point_solid(pos)
			var pos3d := SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.xy_Vector2iToVector3i(pos,0))
			$MultiMeshShape.set_inst_position(inst_index, pos3d)
			$MultiMeshShape.set_inst_color(inst_index, co)
			inst_index += 1
	$MultiMeshShape.set_visible_count(inst_index)

func close_startpos() -> void:
	var pos := StartPos
	field.set_at(pos, self)
	astar_grid.set_point_solid(pos)

	var tmp := StartPos+Dir8Lib.Dir2Vt[Dir8Lib.Dir.SouthEast]
	var pos1 := SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.xy_Vector2iToVector3i(tmp,0))
	var pos2 := SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.xy_Vector2iToVector3i(StartPos,0))
	animate_inst = {
		"start_time" : Time.get_unix_time_from_system(),
		"inst_index" : startwall_index,
		"ani_dur_sec" : 1,
		"pos1" : pos1,
		"pos2" : pos2,
	}

func open_goalpos() -> void:
	var pos := GoalPos
	var old = field.set_at( pos, SBGoal.new())
	astar_grid.set_point_solid(pos, false)

	assert(old == self, "invalid goal pos not wall %s %s" % [pos,old])
	var pos1 := SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.xy_Vector2iToVector3i(GoalPos,0))
	var tmp := GoalPos+Dir8Lib.Dir2Vt[Dir8Lib.Dir.NorthWest]
	var pos2 := SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.xy_Vector2iToVector3i(tmp,0))
	animate_inst = {
		"start_time" : Time.get_unix_time_from_system(),
		"inst_index" : goalwall_index,
		"ani_dur_sec" : 1,
		"pos1" : pos1,
		"pos2" : pos2,
	}

func _process(_delta: float) -> void:
	if animate_inst.start_time != 0:
		var rate :float = (Time.get_unix_time_from_system() - animate_inst.start_time) / animate_inst.ani_dur_sec
		var pos :Vector3 = lerp(animate_inst.pos1, animate_inst.pos2, rate )
		$MultiMeshShape.set_inst_position(animate_inst.inst_index, pos)
		if rate >= 1 :
			animate_inst.start_time = 0

func set_at(pos :Vector2i):
	wall_list.append([pos])
# include x2
func draw_hline(x1 :int, x2 :int, y :int):
	if x1 > x2 :
		var t := x1
		x1 = x2
		x2 = t
	var rtn := []
	for x in range(x1,x2+1):
		rtn.append( Vector2i(x,y) )
	wall_list.append(rtn)

# include y2
func draw_vline(x :int, y1 :int, y2 :int):
	if y1 > y2 :
		var t := y1
		y1 = y2
		y2 = t
	var rtn := []
	for y in range(y1,y2+1):
		rtn.append( Vector2i(x,y) )
	wall_list.append(rtn)

func exec_script(sc :Array):
	for l in sc:
		exec_script_line(l)

func exec_script_line(l:Array):
	match l[0]:
		"set" :
			set_at(Vector2i(l[1],l[2]))
		"hline":
			draw_hline(l[1],l[2],l[3])
		"vline":
			draw_vline(l[1],l[2],l[3])
		_:
			assert(false, "invalid script line %s" %[l])
