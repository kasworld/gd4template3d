extends Node3D
class_name BattleShooter

static var ShipSpeed :float = 400
static var BulletSpeed :float = 1000
static var HommingBulletSpeed :float = 600


static var BulletLifeSec :float = 10
static var HommingBulletLifeSec :float = 10
static var ShieldLifeSec :float = 10

# initial value
static var TeamCount :int = 3
static var ShipPerTeam :int = 1
static var ShieldCount :int = 2

static var cabinet_size :Vector3

static func Make2D(vt3 :Vector3) -> Vector2:
	return Vector2(vt3.x, vt3.y)


func init(sz :Vector3) -> BattleShooter:
	cabinet_size = sz
	return self
