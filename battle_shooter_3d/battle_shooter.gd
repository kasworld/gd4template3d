extends Node3D
class_name BattleShooter

static var ColorList := ListIter.new( NamedColors.color_list, true )
static func make_team_list(team_count :int, ship_per_team :int) -> Array[BattleShooterTeam]:
	var rtn :Array[BattleShooterTeam] = []
	for t in team_count:
		var ct := BattleShooterTeam.new(ColorList.get_current_and_step_next(), ship_per_team)
		rtn.append(ct)
	return rtn

# initial value
static var TeamCount :int = 3
static var ShipPerTeam :int = 1
static var ShieldCount :int = 2

static var CabinetSize :Vector3
static var Boundary :AABB

static func Make2D(vt3 :Vector3) -> Vector2:
	return Vector2(vt3.x, vt3.y)

var octtree :OctTree

func init(sz :Vector3) -> BattleShooter:
	CabinetSize = sz
	Boundary = AABB(-CabinetSize/2,CabinetSize)
	#octtree = OctTree.new(Boundary, 100)
	var teams := make_team_list(TeamCount, ShipPerTeam)
	for t in teams:
		var ship :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
			).init(BSObj.Type.Ship, t)
		add_child(ship)
		ship.position = Vector3(
			randf_range(-CabinetSize.x/2,CabinetSize.x/2),
			randf_range(-CabinetSize.y/2,CabinetSize.y/2),
			0,
			)
	return self
