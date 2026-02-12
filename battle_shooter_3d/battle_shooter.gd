extends Node3D
class_name BattleShooter


# initial value
static var TeamCount :int = 3
static var ShipPerTeam :int = 1
static var ShieldCount :int = 2

static var CabinetSize :Vector3

static func Make2D(vt3 :Vector3) -> Vector2:
	return Vector2(vt3.x, vt3.y)


func init(sz :Vector3) -> BattleShooter:
	CabinetSize = sz
	return self
