extends Node3D
class_name BattleShooter

# initial value
static var TeamCount :int = 30
static var ShipPerTeam :int = 1
static var ShieldCount :int = 2

static var ColorList := ListIter.new( NamedColors.color_list, true )
static var TeamList :Array[BattleShooterTeam]
static func MakeTeamList(team_count :int, ship_per_team :int) -> Array[BattleShooterTeam]:
	var rtn :Array[BattleShooterTeam] = []
	for t in team_count:
		var ct := BattleShooterTeam.new(ColorList.get_current_and_step_next(), ship_per_team)
		rtn.append(ct)
	return rtn

static func RandPosInAABB(aabb :AABB) -> Vector3:
	return ClearZ(Vector3(
		randf_range(aabb.position.x, aabb.end.x),
		randf_range(aabb.position.y, aabb.end.y),
		randf_range(aabb.position.z, aabb.end.z),
	))

static func RandVelocityInAABB(aabb :AABB) -> Vector3:
	return ClearZ(Vector3(
		randf_range(-aabb.size.x/2, aabb.size.x/2),
		randf_range(-aabb.size.y/2, aabb.size.y/2),
		randf_range(-aabb.size.z/2, aabb.size.z/2),
	))

static func ClearZ(vt :Vector3) -> Vector3:
	vt.z = 0
	return vt

static func Make2D(vt3 :Vector3) -> Vector2:
	return Vector2(vt3.x, vt3.y)

static var Boundary :AABB
var octtree :OctTree

func init(sz :Vector3) -> BattleShooter:
	Boundary = AABB(-sz/2,sz)
	TeamList = MakeTeamList(TeamCount, ShipPerTeam)
	for t_num in TeamList.size():
		for i in ShipPerTeam:
			new_ship(t_num)
	#octtree = OctTree.new(Boundary, 100)
	return self

func new_ship(t_num :int) -> BSObj:
	if TeamList[t_num].calc_tomake_ship() <= 0:
		print_debug("skip new ship %s" % TeamList[t_num])
		return
	TeamList[t_num].inc_ship_count()
	var ship :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate().init_ship(t_num)
	$ShipContainer.add_child(ship)
	ship.spawn_ended.connect(spawn_ended)
	ship.life_ended.connect(life_ended)
	ship.explode_ended.connect(explode_ended)
	ship.position = RandPosInAABB(Boundary)
	return ship

func new_bullet(t_num :int, shippos :Vector3, velocity :Vector3) -> BSObj:
	var bullet :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate().init_bullet(t_num)
	$BulletContainer.add_child(bullet)
	bullet.spawn_ended.connect(spawn_ended)
	bullet.life_ended.connect(life_ended)
	bullet.explode_ended.connect(explode_ended)
	bullet.position = shippos + velocity * BSObj.CalcRefSpeed(BSObj.Type.Bullet)
	bullet.velocity = velocity
	return bullet

func new_homming(t_num :int, shippos :Vector3, velocity :Vector3) -> BSObj:
	var homming :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate().init_homming(t_num)
	$HommingContainer.add_child(homming)
	homming.spawn_ended.connect(spawn_ended)
	homming.life_ended.connect(life_ended)
	homming.explode_ended.connect(explode_ended)
	homming.position = shippos + velocity * BSObj.CalcRefSpeed(BSObj.Type.Homming)
	homming.velocity = velocity
	return homming


func spawn_ended(_me :BSObj) -> void:
	pass
func life_ended(_me :BSObj, _other :BSObj) -> void:
	pass
func explode_ended(me :BSObj) -> void:
	var t_num := me.team_number
	match me.type:
		BSObj.Type.Ship:
			$ShipContainer.remove_child(me)
		BSObj.Type.Bullet:
			$BulletContainer.remove_child(me)
		BSObj.Type.Homming:
			$HommingContainer.remove_child(me)
		_ :
			print_debug("unhandled obj %s" % me)
		# shield handle in BSObj
	me.queue_free()
	match me.type:
		BSObj.Type.Ship:
			TeamList[t_num].dec_ship_count()
			#print_debug(me.team)
			new_ship(t_num)
		_ :
			pass
