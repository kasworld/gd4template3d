extends Area3D
class_name BSObj

enum Type {Ship, Bullet, Homming, Shield}

## by cabinetsize
static var SizeRate := {
	Type.Ship :    0.01,
	Type.Bullet :  0.01,
	Type.Homming : 0.01,
	Type.Shield :  0.01,
}

## by cabinetsize
static var SpeedRate := {
	Type.Ship :    0.1,
	Type.Bullet :  0.1,
	Type.Homming : 0.1,
	Type.Shield :  0.1,
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

func _init(t :Type, tm :BattleShooterTeam) -> void:
	team = tm
	type = t
	collision_layer = BitFlag.ByPos(type)
	collision_mask = mask_dict[type]
	match type:
		Type.Ship:
			$MeshInstance3D.mesh = SphereMesh.new()
			$MeshInstance3D.mesh.radius = BattleShooter.CabinetSize.x * SizeRate[type]
		Type.Bullet:
			$MeshInstance3D.mesh = CapsuleMesh.new()
			$MeshInstance3D.mesh.radius = BattleShooter.CabinetSize.x * SizeRate[type]
			$MeshInstance3D.mesh.height = BattleShooter.CabinetSize.x * SizeRate[type] *2
		Type.Homming:
			$MeshInstance3D.mesh = TorusMesh.new()
			$MeshInstance3D.mesh.inner_radius = BattleShooter.CabinetSize.x * SizeRate[type] /2
			$MeshInstance3D.mesh.outer_radius = BattleShooter.CabinetSize.x * SizeRate[type]
		Type.Shield:
			$MeshInstance3D.mesh = SphereMesh.new()
			$MeshInstance3D.mesh.radius = BattleShooter.CabinetSize.x * SizeRate[type]
	$MeshInstance3D.mesh.material = MultiMeshShape.make_color_material()
	$MeshInstance3D.mesh.material.albedo_color = team.color
