extends MultiMeshInstance3D
class_name MultiMeshShape

static func 집중선만들기(r :float, start:float, end:float, depth :float, count :int, co :Color ) -> MultiMeshShape:
	var 구분선 := BoxMesh.new()
	var 길이 := r*(end-start)
	구분선.size = Vector3(길이, depth/10, depth )
	var cell각도 := 2.0*PI / count
	var radius := r-길이/2
	var mms :MultiMeshShape = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate().init(
		구분선, Color.WHITE, count ,Vector3.ZERO )
	for i in count:
		var rad := cell각도 *i + cell각도/2
		mms.set_inst_rotation(i, Vector3.BACK, rad)
		mms.set_inst_pos(i, Vector3(cos(rad) *radius,sin(rad) *radius, 0) )
		mms.set_inst_color(i, co)
	return mms


var m_mesh :MultiMesh

func init(mesh :Mesh, co :Color, count :int, pos :Vector3) -> MultiMeshShape:
	var mat := StandardMaterial3D.new()
	# draw call 이 TRANSPARENCY_ALPHA 인 경우만 줄어든다. 버그인가?
	if co.a >= 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	else:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = co
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
		#m_mesh.set_instance_color(i,Color.WHITE)
		var t := Transform3D(Basis(), pos)
		m_mesh.set_instance_transform(i,t)
	return self

func set_visible_count(i :int) -> void:
	m_mesh.visible_instance_count = i

func get_visible_count() -> int:
	return m_mesh.visible_instance_count

func set_inst_rotation(i :int, axis :Vector3, rot :float) -> void:
	var t := m_mesh.get_instance_transform(i)
	t = t.rotated_local(axis, rot)
	m_mesh.set_instance_transform(i,t )

func set_inst_pos(i :int, pos :Vector3) -> void:
	var t := m_mesh.get_instance_transform(i)
	t.origin = pos
	m_mesh.set_instance_transform(i,t )

func set_inst_color(i, co :Color) -> void:
	m_mesh.set_instance_color(i,co)
