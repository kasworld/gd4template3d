extends MultiMeshInstance3D
class_name MultiMeshShape

var m_mesh :MultiMesh

func init(mesh :Mesh, co :Color, count :int, pos :Vector3) -> MultiMeshShape:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.vertex_color_use_as_albedo = true
	mesh.material = mat
	m_mesh = MultiMesh.new()
	m_mesh.mesh = mesh
	m_mesh.transform_format = MultiMesh.TRANSFORM_3D
	m_mesh.use_colors = true # before set instance_count
	# Then resize (otherwise, changing the format is not allowed).
	m_mesh.instance_count = count
	m_mesh.visible_instance_count = count
	$".".multimesh = m_mesh
	for i in m_mesh.visible_instance_count:
		m_mesh.set_instance_color(i,co)
		var t = Transform3D(Basis(), pos)
		m_mesh.set_instance_transform(i,t)
	return self

func set_visible_count(i :int) -> void:
	m_mesh.visible_instance_count = i

func get_visible_count() -> int:
	return m_mesh.visible_instance_count

func set_inst_rotation(i :int, axis :Vector3, rot :float) -> void:
	var t = m_mesh.get_instance_transform(i)
	t = t.rotated_local(axis, rot)
	m_mesh.set_instance_transform(i,t )

func set_inst_pos(i :int, pos :Vector3) -> void:
	var t = m_mesh.get_instance_transform(i)
	t.origin = pos
	m_mesh.set_instance_transform(i,t )

func set_inst_color(i, co :Color) -> void:
	m_mesh.set_instance_color(i,co)
