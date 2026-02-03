extends MeshInstance3D

class_name 다각기둥

func init(반지름 :float, 높이 :float, 색깔 :Color, 각수 :int = 64) -> 다각기둥:
	#mesh = CylinderMesh.new()
	mesh.bottom_radius = 반지름
	mesh.top_radius = 반지름
	mesh.height = 높이
	mesh.radial_segments = 각수
	mesh.material = MultiMeshShape.make_color_material()
	mesh.material.albedo_color = 색깔
	rotation.x = PI/2
	return self

func set_color(co :Color) -> void:
	mesh.material.albedo_color = co

func flip_face(b :bool) -> void:
	mesh.flip_faces = b
