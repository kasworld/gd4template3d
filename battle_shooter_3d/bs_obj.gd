extends Area3D
class_name BSObj

enum Type {Ship, Bullet, Homming, Shield}

var type :Type
var alive :bool
var team :BattleShooterTeam

func _init(t :Type) -> void:
	type = t
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(t, true)
	match type:
		Type.Ship:
			set_collision_mask_value(Type.Ship, true)
			set_collision_mask_value(Type.Bullet, true)
			set_collision_mask_value(Type.Homming, true)
			set_collision_mask_value(Type.Shield, true)
			$MeshInstance3D.mesh = SphereMesh.new()
		Type.Bullet:
			set_collision_mask_value(Type.Ship, true)
			set_collision_mask_value(Type.Bullet, true)
			set_collision_mask_value(Type.Shield, true)
			$MeshInstance3D.mesh = CapsuleMesh.new()
		Type.Homming:
			set_collision_mask_value(Type.Ship, true)
			set_collision_mask_value(Type.Homming, true)
			set_collision_mask_value(Type.Shield, true)
			$MeshInstance3D.mesh = TorusMesh.new()
		Type.Shield:
			set_collision_mask_value(Type.Ship, true)
			set_collision_mask_value(Type.Bullet, true)
			set_collision_mask_value(Type.Homming, true)
			set_collision_mask_value(Type.Shield, true)
			$MeshInstance3D.mesh = SphereMesh.new()
	$MeshInstance3D.mesh.material = MultiMeshShape.make_color_material()
