extends Node3D
class_name BattleShooter

# initial value
static var TeamCount :int = 3
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
func build_octtree()->void:
	var count := $ShipContainer.get_child_count() + $BulletContainer.get_child_count() + $HommingContainer.get_child_count()
	octtree = OctTree.new(Boundary, count)
	for o in $ShipContainer.get_children():
		octtree.insert(o.position, o)
	for o in $BulletContainer.get_children():
		octtree.insert(o.position, o)
	for o in $HommingContainer.get_children():
		octtree.insert(o.position, o)

func _process(delta: float) -> void:
	build_octtree()
	for ship in $ShipContainer.get_children():
		ship.ship_ai_act(delta, self)

func get_ship_list()->Array:
	return $ShipContainer.get_children()

func init(sz :Vector3) -> BattleShooter:
	Boundary = AABB(-sz/2,sz)
	TeamList = MakeTeamList(TeamCount, ShipPerTeam)
	for t_num in TeamList.size():
		for i in ShipPerTeam:
			new_ship(t_num)
	return self

func new_ship(t_num :int) -> BSObj:
	if TeamList[t_num].calc_tomake_ship() <= 0:
		print_debug("skip new ship %s" % TeamList[t_num])
		return
	TeamList[t_num].inc_ship_count()
	var ship :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
		).init_ship(t_num)
	$ShipContainer.add_child(ship)
	#ship.spawn_ended.connect(spawn_ended)
	#ship.life_ended.connect(life_ended)
	ship.explode_ended.connect(explode_ended)
	ship.position = RandPosInAABB(Boundary)
	return ship

func new_bullet(src_ship :BSObj, velocity :Vector3) -> BSObj:
	var bullet :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
		).init_bullet(src_ship.team_number, velocity)
	$BulletContainer.add_child(bullet)
	#bullet.spawn_ended.connect(spawn_ended)
	#bullet.life_ended.connect(life_ended)
	bullet.explode_ended.connect(explode_ended)
	var dir := velocity.normalized()
	bullet.position = src_ship.position + dir * BSObj.CalcRefSize(BSObj.Type.Ship)*2
	return bullet

func new_homming(src_ship :BSObj, dstobj :BSObj) -> BSObj:
	var homming :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
		).init_homming(src_ship.team_number, dstobj)
	$HommingContainer.add_child(homming)
	#homming.spawn_ended.connect(spawn_ended)
	#homming.life_ended.connect(life_ended)
	homming.explode_ended.connect(explode_ended)
	var dir := src_ship.position.direction_to(dstobj.position)
	homming.position = src_ship.position + dir * BSObj.CalcRefSize(BSObj.Type.Ship)*2
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
