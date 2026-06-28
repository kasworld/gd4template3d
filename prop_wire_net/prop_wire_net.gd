extends Node3D
class_name PropWireNet

static func make_box(box_size :Vector3, box_mat :StandardMaterial3D) -> CSGShape3D:
	var box := CSGBox3D.new()
	box.size = box_size
	box.material = box_mat
	return box

static func MakeColorMaterial(co :Color, transparent :bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = co
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent else BaseMaterial3D.TRANSPARENCY_DISABLED
	return material

static func MakeCSG() -> CSGShape3D:
	var center := make_box(Vector3.ONE, MakeColorMaterial(Color(0,0,0,0), true) )
	return center

func init(top_size :Vector3, leg_size :Vector3, co_top :Color, co_leg :Color) -> PropWireNet:
	var wall := MakeCSG()
	bake.call_deferred(wall)
	return self

func bake(csg :CSGShape3D) -> void:
	$MeshInstance3D.mesh = csg.bake_static_mesh()
