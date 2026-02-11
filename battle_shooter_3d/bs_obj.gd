extends Area3D
class_name BSObj

enum Type {Ship, Bullet, Homming, Shield}

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
		Type.Bullet:
			$MeshInstance3D.mesh = CapsuleMesh.new()
		Type.Homming:
			$MeshInstance3D.mesh = TorusMesh.new()
		Type.Shield:
			$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.material = MultiMeshShape.make_color_material()
