extends Area3D
class_name BSObj

signal life_ended(me :BSObj, other :BSObj)
signal explode_ended(me :BSObj)

enum Type {Ship, Bullet, Homming, Shield}

## by cabinetsize
static var SizeRate :Dictionary[Type,float] = {
	Type.Ship :    0.01,
	Type.Bullet :  0.005,
	Type.Homming : 0.01,
	Type.Shield :  0.005,
}

## by cabinetsize
static var SpeedRate :Dictionary[Type,float]= {
	Type.Ship :    0.5,
	Type.Bullet :  0.5,
	Type.Homming : 0.5,
	Type.Shield :  0.5,
}

static var LifeSec :Dictionary[Type,float]= {
	Type.Ship :    10.0,
	Type.Bullet :  10.0,
	Type.Homming : 10.0,
	Type.Shield :  10.0,
}

var mask_dict :Dictionary[Type,int] = {
	Type.Ship :    BitFlag.FromPosList2(Type.Ship,Type.Bullet,Type.Homming,Type.Shield),
	Type.Bullet :  BitFlag.FromPosList2(Type.Ship,Type.Bullet,             Type.Shield),
	Type.Homming : BitFlag.FromPosList2(Type.Ship,            Type.Homming,Type.Shield),
	Type.Shield :  BitFlag.FromPosList2(Type.Ship,Type.Bullet,Type.Homming,Type.Shield),
}

var type :Type
var alive :bool
var team :BattleShooterTeam
var animation_explode := SimpleAnimation.new()
var velocity :Vector3
var bounce_radius :float


func init0(t :Type, tm :BattleShooterTeam) -> void:
	team = tm
	type = t
	collision_layer = BitFlag.ByPos(type)
	collision_mask = mask_dict[type]

func init1() -> void:
	$MeshInstance3D.mesh.material = MultiMeshShape.make_color_material()
	$MeshInstance3D.mesh.material.albedo_color = team.color
	velocity = BattleShooter.RandVelocityInAABB(BattleShooter.Boundary)*SpeedRate[type]
	animation_explode.animation_ended.connect(animation_ended)
	alive = true

var shield_list :Array[BSObj]
func init_ship(tm :BattleShooterTeam) -> BSObj:
	init0(Type.Ship,tm)
	var ref_len := BattleShooter.Boundary.size.length()
	$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.radius = ref_len * SizeRate[type]
	$MeshInstance3D.mesh.height = ref_len * SizeRate[type] *2
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	bounce_radius = $MeshInstance3D.mesh.radius
	init1()
	for i in BattleShooter.ShieldCount:
		shield_list.append(new_shield(tm))
	return self

func new_shield(t :BattleShooterTeam) -> BSObj:
	var shield :BSObj = preload("res://battle_shooter_3d/bs_obj.tscn").instantiate(
		).init_shield(t)
	add_child(shield)
	shield.life_ended.connect(shield_life_ended)
	shield.explode_ended.connect(shield_explode_ended)
	return shield
func shield_life_ended(me :BSObj, other :BSObj) -> void:
	pass
func shield_explode_ended(me :BSObj) -> void:
	me.queue_free()

var shield_rotate_dir :float
func init_shield(tm :BattleShooterTeam) -> BSObj:
	init0(Type.Shield,tm)
	var ref_len := BattleShooter.Boundary.size.length()
	$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.radius = ref_len * SizeRate[type]
	$MeshInstance3D.mesh.height = ref_len * SizeRate[type] *2
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	init1()
	shield_rotate_dir = randfn(-PI,PI)
	var shield_orbit_r :float = ref_len * SizeRate[Type.Ship] *2
	position = Vector3(shield_orbit_r, 0,0)
	return self

func init_bullet(tm :BattleShooterTeam) -> BSObj:
	init0(Type.Bullet,tm)
	var ref_len := BattleShooter.Boundary.size.length()
	$MeshInstance3D.mesh = CapsuleMesh.new()
	$MeshInstance3D.mesh.radius = ref_len * SizeRate[type]
	$MeshInstance3D.mesh.height = ref_len * SizeRate[type] *2
	$CollisionShape3D.shape = CapsuleShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	$CollisionShape3D.shape.height = $MeshInstance3D.mesh.height
	init1()
	return self

func init_homming(tm :BattleShooterTeam) -> BSObj:
	init0(Type.Homming,tm)
	var ref_len := BattleShooter.Boundary.size.length()
	$MeshInstance3D.mesh = TorusMesh.new()
	$MeshInstance3D.mesh.inner_radius = ref_len * SizeRate[type] /2
	$MeshInstance3D.mesh.outer_radius = ref_len * SizeRate[type]
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.outer_radius
	init1()
	return self


func end_life(other :BSObj) -> void:
	alive = false
	collision_layer = 0
	collision_mask = 0
	life_ended.emit(self, other)
	match type:
		Type.Ship:
			animation_explode.start_scale("ship_explode1", $MeshInstance3D, Vector3(1,1,1), Vector3(2,2,2), 0.2)
			#for s in shield_list:
				#s.end_life(null)
		Type.Shield:
			animation_explode.start_scale("shield_explode1", $MeshInstance3D, Vector3(1,1,1), Vector3(2,2,2), 0.2)

func animation_ended(_st :Node, ani :Dictionary) -> void:
	match ani.Name:
		"ship_explode1":
			animation_explode.start_scale("ship_explode2", $MeshInstance3D, Vector3(2,2,2), Vector3(0.1,0.1,0.1), 0.2)
		"shield_explode1":
			animation_explode.start_scale("shield_explode2", $MeshInstance3D, Vector3(2,2,2), Vector3(0.1,0.1,0.1), 0.2)
		_ :
			explode_ended.emit(self)

func _process(_delta: float) -> void:
	animation_explode.handle_animation()

func _physics_process(delta: float) -> void:
	if not alive:
		velocity *= 0.99
	match type:
		Type.Ship:
			position += velocity * delta
			var bn := Bounce.v3f(position,BattleShooter.Boundary,bounce_radius)
			position = bn.pos
			for i in 3:
				# change vel on bounce
				if bn.bounced[i] != 0 :
					velocity[i] = -bn.bounced[i] * abs(velocity[i])
		Type.Shield:
			position = position.rotated(Vector3.FORWARD, delta*shield_rotate_dir)
	#$DirSprite.position = Vector2.RIGHT.rotated(velocity.angle())*20

func _on_area_entered(area: Area3D) -> void:
	assert(area is BSObj)
	if area.team == team:
		return
	end_life(area as BSObj)
