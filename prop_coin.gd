extends Node3D
class_name Coin

## face Z+
func init(size :Vector3, co :Color) -> Coin:
	var wall := MakeCoinMesh(size,MakeColorMaterial(co))
	bake.call_deferred(wall)
	return self

func bake(csg :CSGShape3D) -> void:
	$MeshInstance3D.mesh = csg.bake_static_mesh()

## face Z+
static func MakeCoinMesh(size :Vector3, mat :StandardMaterial3D) -> CSGShape3D:
	var wall := CSGBox3D.new()
	wall.size = size
	wall.material = mat
	var door_low := CSGBox3D.new()
	door_low.size = Vector3(size.x/2,size.y/2,size.z)
	door_low.material = mat
	door_low.operation = CSGShape3D.OPERATION_SUBTRACTION
	door_low.position.y = -size.y * 0.25
	var hole := CSGCylinder3D.new()
	hole.material = mat
	hole.radius = size.x/4
	hole.height = size.z *2
	hole.sides = 64
	hole.rotate_x(PI/2)
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	wall.add_child(door_low)
	wall.add_child(hole)
	return wall

static func MakeColorMaterial(co :Color, transparent :bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = co
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent else BaseMaterial3D.TRANSPARENCY_DISABLED
	return material
