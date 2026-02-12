extends Node3D
class_name BattleShooter

static var ColorList := ListIter.new( NamedColors.color_list, true )
static func MakeTeamList(team_count :int, ship_per_team :int) -> Array[BattleShooterTeam]:
	var rtn :Array[BattleShooterTeam] = []
	for t in team_count:
		var ct := BattleShooterTeam.new(ColorList.get_current_and_step_next(), ship_per_team)
		rtn.append(ct)
	return rtn

static func RandPosInAABB(aabb :AABB) -> Vector3:
	return Vector3(
		randf_range(aabb.position.x, aabb.end.x),
		randf_range(aabb.position.y, aabb.end.y),
		0,
	)

static func RandVelocityInAABB(aabb :AABB) -> Vector3:
	return Vector3(
		randf_range(-aabb.size.x/2, aabb.size.x/2),
		randf_range(-aabb.size.y/2, aabb.size.y/2),
		0,
	)

static func ClearZ(vt :Vector3) -> Vector3:
	vt.z = 0
	return vt

static func Make2D(vt3 :Vector3) -> Vector2:
	return Vector2(vt3.x, vt3.y)

# initial value
static var TeamCount :int = 3
static var ShipPerTeam :int = 1
static var ShieldCount :int = 2

static var Boundary :AABB


var octtree :OctTree

func init(sz :Vector3) -> BattleShooter:
	Boundary = AABB(-sz/2,sz)
	#octtree = OctTree.new(Boundary, 100)
	var teams := MakeTeamList(TeamCount, ShipPerTeam)
	for t in teams:
		var ship :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
			).init(BSObj.Type.Ship, t)
		add_child(ship)
		ship.position = RandPosInAABB(Boundary)
	return self
