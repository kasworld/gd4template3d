class_name Maze3DSetting

static func new_default() -> Maze3DSetting:
	return new()

func _to_string() -> String:
	return "Maze3DSetting[size:%s height:%.1f lane width:%.1f wall thick:%.1f]" % [
		MazeSize, StoryH, LaneW, WallThick,
	]

var MazeSize :Vector2i
var StoryH :float
var LaneW :float
var WallThick :float
var MakeSubWallRate :float
var calc_grid :CalcGrid3D

func _init(
	size :Vector2i = Vector2i(4,4),
	height :float = 3.0,
	lane_width :float = 4.0,
	wall_thick :float = 4.0*0.05,
	subwall_rate :float = 1.0/(4*4)
	) -> void:
	MazeSize = size
	StoryH = height
	LaneW = lane_width
	WallThick = wall_thick
	MakeSubWallRate = subwall_rate

	var sz := Vector3(LaneW*MazeSize.x, LaneW*MazeSize.y, StoryH)
	calc_grid = CalcGrid3D.new(
		CalcGrid3D.SizeToAABB(sz),
		CalcGrid3D.Vector2iToVector3i(MazeSize, 1),
		)
	#print_debug(calc_grid)

func duplicate() -> Maze3DSetting:
	return new(MazeSize,StoryH,LaneW,WallThick,MakeSubWallRate)

## CalcGrid3D funcs

func CalcCellCount() -> int:
	return calc_grid.get_grid_count()

func CellSize() -> Vector3:
	return calc_grid.unit_size

func CalcSizeV3() -> Vector3:
	return calc_grid.boundary.size

func mazepos2storeypos( mp :Vector2i, z :float) -> Vector3:
	var rtn := calc_grid.posi_to_lanepos( CalcGrid3D.Vector2iToVector3i(mp,0) )
	rtn.z = z
	return rtn

func storeypos2mazepos(pos :Vector3) -> Vector2i:
	var rtn := calc_grid.lanepos_to_posi(pos)
	return CalcGrid3D.Vector3iToVector2i(rtn)

func rand_pos_2i() -> Vector2i:
	return Vector2i(randi_range(0,MazeSize.x-1),randi_range(0,MazeSize.y-1) )

func PillarSize() -> Vector3:
	return Vector3(WallThick,WallThick,StoryH)
# without wall
func CalcSizeV2() -> Vector2:
	return MazeSize*LaneW

# with wall
func CalcSizeWithWallV2() -> Vector2:
	return CalcSizeV2() + Vector2(WallThick, WallThick)
func CalcSizeWithWallV3() -> Vector3:
	var sz := CalcSizeWithWallV2()
	return Vector3(sz.x,sz.y,StoryH)

func CalcWallSize_H_Long() -> Vector3:
	return Vector3(LaneW, WallThick, StoryH)
func CalcWallSize_H_Short() -> Vector3:
	return CalcWallSize_H_Long() - Vector3(WallThick, 0, 0)

func CalcWallSize_V_Long() -> Vector3:
	return swap_xy(CalcWallSize_H_Long())
func CalcWallSize_V_Short() -> Vector3:
	return swap_xy(CalcWallSize_H_Short())

static func swap_xy(src :Vector3) -> Vector3:
	return Vector3(src.y,src.x,src.z)
