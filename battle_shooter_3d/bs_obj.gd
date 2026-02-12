extends Area3D
class_name BSObj

signal life_ended(me :BSObj)
signal explode_ended(me :BSObj)

enum Type {Ship, Bullet, Homming, Shield}

## by cabinetsize
static var SizeRate := {
	Type.Ship :    0.01,
	Type.Bullet :  0.005,
	Type.Homming : 0.01,
	Type.Shield :  0.005,
}

## by cabinetsize
static var SpeedRate := {
	Type.Ship :    0.5,
	Type.Bullet :  0.5,
	Type.Homming : 0.5,
	Type.Shield :  0.5,
}

static var LifeSec := {
	Type.Ship :    10.0,
	Type.Bullet :  10.0,
	Type.Homming : 10.0,
	Type.Shield :  10.0,
}

var mask_dict := {
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

func init_shield(tm :BattleShooterTeam) -> BSObj:
	init0(Type.Shield,tm)
	var ref_len := BattleShooter.Boundary.size.length()
	$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.radius = ref_len * SizeRate[type]
	$MeshInstance3D.mesh.height = ref_len * SizeRate[type] *2
	$CollisionShape3D.shape = SphereShape3D.new()
	$CollisionShape3D.shape.radius = $MeshInstance3D.mesh.radius
	init1()
	return self


func _physics_process(delta: float) -> void:
	if type != Type.Ship:
		return
	position += velocity * delta
	var bn := Bounce.v3f(position,BattleShooter.Boundary,bounce_radius)
	position = bn.pos
	for i in 3:
		# change vel on bounce
		if bn.bounced[i] != 0 :
			velocity[i] = -bn.bounced[i] * abs(velocity[i])
	#$DirSprite.position = Vector2.RIGHT.rotated(velocity.angle())*20
