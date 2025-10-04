extends Node3D

const WorldSize := Vector3(40,22,1)

func _ready() -> void:
	get_viewport().size_changed.connect(on_viewport_size_changed)
	var vp_size = get_viewport().get_visible_rect().size
	var 짧은길이 = min(vp_size.x,vp_size.y)
	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)

	set_walls()
	reset_camera_pos()

	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect, tr("gd4template3d 1.0.0"))
	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)

	orbit_test()
	wirenet_test()
	bartree_test()
	calendar_test()
	clock_test()
	line2d_test()

func mashtrail_test() -> void:
	var mt = preload("res://mesh_trail/mesh_trail.tscn").instantiate(
	)
	add_child(mt)

func line2d_test() -> void:
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(WorldSize.x, WorldSize.y)
	mesh.orientation = PlaneMesh.FACE_Z
	#mesh.flip_faces = flip
	var size_pixel = Vector2i(2048,2048)
	var l2d = preload("res://move_line2d/move_line_2d.tscn").instantiate().init_with_random(300, 4, 1, size_pixel)
	l2d.start()
	var sv = SubViewport.new()
	sv.size = size_pixel
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	#sv.transparent_bg = true
	sv.add_child(l2d)
	add_child(sv)
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	sp.position = WorldSize/2 - Vector3(0,0,0.7)
	sp.material_override = StandardMaterial3D.new()
	#sp.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	sp.material_override.albedo_texture = sv.get_texture()
	add_child(sp)


func orbit_test() -> void:
	var diagonal_length = WorldSize.length()/2
	var a120 = PI*2/3
	var a30 = PI/6
	var axis1 = Vector3.UP.rotated(Vector3.RIGHT, a30)
	var os = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate()
	var mat1 = StandardMaterial3D.new()
	mat1.albedo_color = Color.GREEN
	var mat2 = StandardMaterial3D.new()
	mat2.albedo_color = Color.RED
	os.궤도설정(diagonal_length*1.1, 1.0/3, axis1, a120*2).구설정(2, 1, Vector3.UP).구재질설정(mat2).궤도재질설정(mat1)
	os.position = WorldSize/2
	add_child(os)

func calendar_test() -> void:
	var ca = preload("res://calendar3d/calendar_3d.tscn").instantiate(
		).init(WorldSize.x/2, WorldSize.y, WorldSize.z, WorldSize.y/2.0 , false )
	ca.rotate_y(PI/2)
	ca.rotate_x(PI/2)
	ca.position = Vector3(WorldSize.x/4,WorldSize.y/2,WorldSize.z/2)
	add_child(ca)

func clock_test() -> void:
	var ca = preload("res://analogclock3d/analog_clock_3d.tscn").instantiate(
		).init(WorldSize.x/4, WorldSize.z, WorldSize.y/2.0 ,9.0, false )
	ca.rotate_y(PI/2)
	ca.rotate_x(PI/2)
	ca.position = Vector3(WorldSize.x/4*3,WorldSize.y/2,WorldSize.z/2)
	add_child(ca)

func wirenet_test() -> void:
	var wn = preload("res://wire_net/wire_net.tscn").instantiate()
	wn.init_with_color(Vector2(40,22), Vector2(41,23), 0.1, Color.BLUE)
	add_child(wn)

func bartree_test() -> void:
	var bt = make_tree(WorldSize.x/3, WorldSize.y/3)
	bt.rotate_x(PI/2)
	bt.position = WorldSize/2
	add_child(bt)
func make_tree(tree_width :float, tree_height :float)->BarTree2:
	var bar_width = tree_width * randf_range(0.5 , 2.0)/10
	var bar_count := randf_range(5,200)
	var bar_rotation := 0.1
	var bar_rotation_begin := randf_range(0,2*PI)
	var t :BarTree2= preload("res://bar_tree_2/bar_tree_2.tscn").instantiate().init_common_params(
		tree_width, tree_height, bar_width, bar_count, bar_rotation, bar_rotation_begin, 0, true
		).init_with_color(random_color(), random_color() )
	return t
func random_color()->Color:
	return Color(randf(),randf(),randf())

func on_viewport_size_changed():
	pass
	
func message_hidden(_s :String) -> void:
	pass

func set_walls() -> void:
	$WallBox.mesh.size = WorldSize + Vector3(1,1,0)
	$WallBox.position = WorldSize/2 - Vector3(0,0,0.5)
	$OmniLight3D.position = WorldSize/2 + Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2

var camera_move = false
func _process(_delta: float) -> void:
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*WorldSize.x/2, cos(t)*WorldSize.y/2, WorldSize.length()*0.4 ) + WorldSize/2
		$Camera3D.look_at(WorldSize/2)

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()

func _on_카메라변경_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(WorldSize.x/2, WorldSize.y/2, WorldSize.x/2 *1.1)
	$Camera3D.look_at(WorldSize/2)
	$Camera3D.far = WorldSize.length()
