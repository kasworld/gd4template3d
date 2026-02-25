extends MeshInstance3D
class_name MazeBall

var velocity :Vector3
var radius :float
func init(co :Color, l :float) -> MazeBall:
	radius = l
	mesh = BoxMesh.new()
	mesh.size = Vector3(l,l,l/4)
	mesh.material = MultiMeshShape.make_color_material()
	mesh.material.albedo_color = co
	velocity = Vector3(randf(),randf(),randf()) * l*10
	return self
