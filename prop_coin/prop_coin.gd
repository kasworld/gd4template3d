extends Node3D
class_name PropCoin

const RRate := 0.95

## face Y+
func init(radius :float, thick :float, co :Color, side :int = 64, front :String ="", back :String="") -> PropCoin:
	var center := MakeCoinCSG(radius, thick, MakeColorMaterial(co), side)
	center = AddTextCSG(center, radius, thick, MakeColorMaterial(co), front, back)
	bake.call_deferred(center)
	return self

## face Y+
static func MakeCoinCSG(raidus :float, thick :float, mat :StandardMaterial3D, side :int = 64) -> CSGShape3D:
	var csg_main := MakeCSGCylinder(raidus, thick, mat, side)
	#csg_main.rotate_x(PI/2)
	var csg_front := MakeCSGCylinder(raidus* RRate, thick/2, mat, side)
	csg_front.position.y = thick /2
	csg_front.operation = CSGShape3D.OPERATION_SUBTRACTION
	csg_main.add_child(csg_front)
	var csg_back := MakeCSGCylinder(raidus* RRate, thick/2, mat, side)
	csg_back.position.y = -thick /2
	csg_back.operation = CSGShape3D.OPERATION_SUBTRACTION
	csg_main.add_child(csg_back)
	return csg_main

static func AddTextCSG(center :CSGShape3D, raidus :float, thick :float, mat :StandardMaterial3D, front :String ="", back :String="") -> CSGShape3D:
	if not front.is_empty():
		var front_text := CSGMesh3D.new()
		front_text.mesh = MakeTextMesh(raidus*1.5/back.length(), thick/2, mat, front)
		front_text.material = mat
		front_text.operation = CSGShape3D.OPERATION_UNION
		front_text.rotate_x(-PI/2)
		front_text.position.y = thick/4
		center.add_child(front_text)
	if not back.is_empty():
		var back_text := CSGMesh3D.new()
		back_text.mesh = MakeTextMesh(raidus*1.5/back.length(), thick/2, mat, back)
		back_text.material = mat
		back_text.operation = CSGShape3D.OPERATION_UNION
		back_text.rotate_x(PI/2)
		back_text.position.y = -thick/4
		center.add_child(back_text)
	return center

func bake(csg :CSGShape3D) -> void:
	$MeshInstance3D.mesh = csg.bake_static_mesh()

static var font := preload("res://font/HakgyoansimBareondotumR.ttf")
static func MakeTextMesh(fsize :float, fdepth :float, mat :Material, text :String) -> Mesh:
	var mesh := TextMesh.new()
	mesh.font = font
	mesh.depth = fdepth
	mesh.pixel_size = fsize / 16
	mesh.text = text
	mesh.material = mat
	return mesh

static func MakeCSGCylinder(raidus :float, thick :float, mat :StandardMaterial3D, side :int = 64) -> CSGShape3D:
	var csg := CSGCylinder3D.new()
	csg.radius = raidus
	csg.height = thick
	csg.sides = side
	csg.material = mat
	return csg

static func MakeCSGBox(box_size :Vector3, box_mat :StandardMaterial3D) -> CSGShape3D:
	var box := CSGBox3D.new()
	box.size = box_size
	box.material = box_mat
	return box

static func MakeColorMaterial(co :Color, transparent :bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = co
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent else BaseMaterial3D.TRANSPARENCY_DISABLED
	return material

## make dummy center
static func MakeDummyCenter() -> CSGShape3D:
	var center := MakeCSGBox(Vector3.ONE/1000, MakeColorMaterial(Color(0,0,0,0), true) )
	return center
