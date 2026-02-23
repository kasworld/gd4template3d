extends Area3D
class_name BSObj

const AniDurSec := 0.2

signal spawn_ended(me :BSObj)
signal life_ended(me :BSObj, other :BSObj)
signal explode_ended(me :BSObj)

enum Type {Ship, Bullet, Homming, Shield}

## by cabinetsize
const SizeRate :Dictionary[Type,float] = {
	Type.Ship :    0.01,
	Type.Bullet :  0.008,
	Type.Homming : 0.008,
	Type.Shield :  0.005,
}

static func CalcRefSize(t :Type) -> float:
	var ref_len := BattleShooter.Boundary.size.length()
	return ref_len * SizeRate[t]

## by cabinetsize
const SpeedRate :Dictionary[Type,float]= {
	Type.Ship :    0.1,
	Type.Bullet :  0.2,
	Type.Homming : 0.1,
	Type.Shield :  0.005,
}

static func CalcRefSpeed(t :Type) -> float:
	var ref_len := BattleShooter.Boundary.size.length()
	return ref_len * SpeedRate[t]

const LifeSec :Dictionary[Type,float]= {
	Type.Ship :    10.0,
	Type.Bullet :  10.0,
	Type.Homming : 10.0,
	Type.Shield :  10.0,
}

static var MaskDict :Dictionary[Type,int] = {
	Type.Ship :    BitFlag.FromPosList2(Type.Ship,Type.Bullet,Type.Homming,Type.Shield),
	Type.Bullet :  BitFlag.FromPosList2(Type.Ship,Type.Bullet,             Type.Shield),
	Type.Homming : BitFlag.FromPosList2(Type.Ship,            Type.Homming,Type.Shield),
	Type.Shield :  BitFlag.FromPosList2(Type.Ship,Type.Bullet,Type.Homming,Type.Shield),
}

var type :Type
var alive :bool
var team_number :int
var animation_bsobj := SimpleAnimation.new()
var velocity :Vector3
var bounce_radius :float

func _to_string() -> String:
	var rtn := "team:%s type:%s alive:%s" % [team_number, Type.keys()[type], alive]
	return rtn

func init_ship(t_num :int) -> BSObj:
	init0(Type.Ship,t_num)
	$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.radius = CalcRefSize(type)
	$MeshInstance3D.mesh.height = CalcRefSize(type) *2
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	bounce_radius = $MeshInstance3D.mesh.radius
	init1()
	velocity = BattleShooter.RandVector3(CalcRefSpeed(type))
	animation_bsobj.start_scale("ship_spawn", $MeshInstance3D, Vector3(0.1,0.1,0.1), Vector3(1,1,1), AniDurSec)
	for i in BattleShooter.ShieldCount:
		new_shield()
	return self

func new_shield() -> BSObj:
	var shield :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
		).init_shield(self)
	$ShieldContainer.add_child(shield)
	#shield.spawn_ended.connect(shield_spawn_ended)
	#shield.life_ended.connect(shield_life_ended)
	shield.explode_ended.connect(shield_explode_ended)
	return shield
#func shield_spawn_ended(_me :BSObj) -> void:
	#pass
#func shield_life_ended(_me :BSObj, _other :BSObj) -> void:
	#pass
func shield_explode_ended(me :BSObj) -> void:
	$ShieldContainer.remove_child.call_deferred(me)
	me.queue_free()

var shield_rotate_dir :float
func init_shield(src_ship :BSObj) -> BSObj:
	init0(Type.Shield,src_ship.team_number)
	$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.radius = CalcRefSize(type)
	$MeshInstance3D.mesh.height = CalcRefSize(type) *2
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	init1()
	src_ship.life_ended.connect(shield_src_ship_life_end)
	animation_bsobj.start_scale("shield_spawn", $MeshInstance3D, Vector3(0.1,0.1,0.1), Vector3(1,1,1), AniDurSec)
	shield_rotate_dir = randfn(-PI,PI) *CalcRefSpeed(type)
	var shield_orbit_r :float = CalcRefSize(Type.Ship) *2
	position = Vector3(shield_orbit_r, 0,0)
	return self
func shield_src_ship_life_end(_src_ship :BSObj, _other :BSObj) -> void:
	end_life(null)

func init_bullet(t_num :int, velocity_a :Vector3) -> BSObj:
	init0(Type.Bullet,t_num)
	$MeshInstance3D.mesh = CapsuleMesh.new()
	$MeshInstance3D.mesh.radius = CalcRefSize(type) * 0.2
	$MeshInstance3D.mesh.height = CalcRefSize(type)
	$MeshInstance3D.rotation.x = PI/2
	$CollisionShape3D.shape = CapsuleShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	$CollisionShape3D.shape.height = $MeshInstance3D.mesh.height
	init1()
	velocity = velocity_a.normalized() * CalcRefSpeed(type)
	look_at_from_position(position, position + velocity_a )
	animation_bsobj.start_scale("bullet_spawn", $MeshInstance3D, Vector3(0.1,0.1,0.1), Vector3(1,1,1), AniDurSec)
	return self

var homming_dst :BSObj
func init_homming(t_num :int, dstobj :BSObj) -> BSObj:
	init0(Type.Homming,t_num)
	$MeshInstance3D.mesh = TorusMesh.new()
	$MeshInstance3D.mesh.inner_radius = CalcRefSize(type) *0.8
	$MeshInstance3D.mesh.outer_radius = CalcRefSize(type)
	$MeshInstance3D.rotation.x = PI/2
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.outer_radius
	init1()
	homming_dst = dstobj
	homming_dst.life_ended.connect(homming_dst_life_end)
	velocity = position.direction_to(homming_dst.position) * CalcRefSpeed(Type.Homming)
	animation_bsobj.start_scale("homming_spawn", $MeshInstance3D, Vector3(0.1,0.1,0.1), Vector3(1,1,1), AniDurSec)
	return self

func homming_dst_life_end(_dst_ship :BSObj, _other :BSObj) -> void:
	homming_dst = null
	end_life(null)

func init0(t :Type, t_num :int) -> void:
	team_number = t_num
	type = t

func init1() -> void:
	$MeshInstance3D.mesh.material = MultiMeshShape.make_color_material()
	$MeshInstance3D.mesh.material.albedo_color = BattleShooter.TeamList[team_number].color
	animation_bsobj.animation_ended.connect(animation_ended)

## end spawn animation
func begin_life() -> void:
	spawn_ended.emit(self)
	alive = true
	collision_layer = BitFlag.ByPos(type)
	collision_mask = MaskDict[type]
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

## start explode animation
func end_life(other :BSObj) -> void:
	if not alive:
		return
	alive = false
	collision_layer = 0
	collision_mask = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	life_ended.emit(self, other)
	match type:
		Type.Ship:
			animation_bsobj.start_scale("ship_explode", $MeshInstance3D, Vector3(1,1,1), Vector3(0.1,0.1,0.1), AniDurSec)
		Type.Shield:
			animation_bsobj.start_scale("shield_explode", $MeshInstance3D, Vector3(1,1,1), Vector3(0.1,0.1,0.1), AniDurSec)
		Type.Bullet:
			animation_bsobj.start_scale("bullet_explode", $MeshInstance3D, Vector3(1,1,1), Vector3(0.1,0.1,0.1), AniDurSec)
		Type.Homming:
			animation_bsobj.start_scale("homming_explode", $MeshInstance3D, Vector3(1,1,1), Vector3(0.1,0.1,0.1), AniDurSec)

func animation_ended(_st :Node, ani :Dictionary) -> void:
	match ani.Name:
		"ship_spawn","shield_spawn","bullet_spawn","homming_spawn" :
			begin_life.call_deferred()
		"ship_explode","shield_explode","bullet_explode","homming_explode":
			explode_ended.emit(self)
		_ :
			print_debug("unhandled end animation %s", ani )

## called from BattleShooter
func ship_ai_act(delta: float, game :BattleShooter) -> void:
	var node_list := game.octree.search(position, BattleShooter.Boundary.size/ sqrt(game.octree_count))
	var danger_dict := BattleShooterAI.find_danger_objs(self,node_list)
#	var danger_dict = {
#		"All":[null, 0.0],
#		"Ball":[null, 0.0],
#		"Bullet":[null, 0.0],
#		"Homming":[null, 0.0],
#	}
	#$DangerPointerContainer.update_danger_dict(self, danger_dict)

	var oldv := velocity
	velocity = BattleShooterAI.accel_to_evade(BattleShooter.Boundary, position, velocity, danger_dict.All[0])
	var team := BattleShooter.TeamList[team_number]
	if oldv != velocity:
		team.stats.Accel +=1

	#var get_ship_list = game.get_ship_list
	var ship_list :Array[BSObj] = []
	for n in game.get_ship_list():
		ship_list.append(n)

	var v := BattleShooterAI.do_fire_bullet(position, team_number, delta, danger_dict, ship_list)
	if v != Vector3.ZERO:
		game.new_bullet(self, v)

	var dst := BattleShooterAI.do_fire_homming(team_number, delta, danger_dict, ship_list)
	if dst != null :
		game.new_homming(self, dst)

	if $ShieldContainer.get_child_count() < BattleShooter.ShieldCount and BattleShooterAI.do_add_shield(delta):
		new_shield()

func _process(delta: float) -> void:
	animation_bsobj.handle_animation()

func _physics_process(delta: float) -> void:
	if not alive:
		return
	match type:
		Type.Ship:
			velocity = BattleShooter.ClearZ(velocity)
			position += velocity * delta
			var bn := Bounce.v3f(position,BattleShooter.Boundary,bounce_radius)
			position = bn.pos
			for i in 3:
				# change vel on bounce
				if bn.bounced[i] != 0 :
					velocity[i] = -bn.bounced[i] * abs(velocity[i])
		Type.Shield:
			position = position.rotated(Vector3.FORWARD, delta*shield_rotate_dir)
		Type.Bullet:
			#rotation = velocity
			position += velocity * delta
			if not BattleShooter.Boundary.has_point(position):
				end_life.call_deferred(self)
		Type.Homming:
			if homming_dst != null:
				$MeshInstance3D.rotate(velocity.normalized(), delta*10)
				position += velocity * delta
				velocity = position.direction_to(homming_dst.position).normalized() * CalcRefSpeed(Type.Homming)
			else:
				end_life(null)


	#$DirSprite.position = Vector2.RIGHT.rotated(velocity.angle())*20

func _on_area_entered(area: Area3D) -> void:
	assert(area is BSObj)
	if area.team_number == team_number:
		return
	end_life.call_deferred(area as BSObj)
