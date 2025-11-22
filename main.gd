extends Node3D

const WorldSize := Vector3(40,22,1)
const AnimationDuration := 1.0

var main_animation := Animation3D.new()
func main_animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	if main_animation.is_empty():
		start_all_animation()
func start_rotate_animation(nd :Node3D, axis :int, ani_dur :float) -> void:
	var diff :float = [PI/2,-PI/2].pick_random()
	main_animation.start_rotate_subfield("ani_rot", nd, axis , nd.rotation[axis], nd.rotation[axis] + diff, ani_dur)
func start_all_animation() -> void:
	start_rotate_animation($Arrow3D,
		[Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random(),
		AnimationDuration)
	start_rotate_animation($ValveHandle, Vector3.Axis.AXIS_Y, AnimationDuration)

func _ready() -> void:
	get_viewport().size_changed.connect(on_viewport_size_changed)
	var vp_size = get_viewport().get_visible_rect().size
	var 짧은길이 = min(vp_size.x,vp_size.y)
	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
	$AxisArrow3D.set_size(5)
	set_walls()
	reset_camera_pos()

	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect, tr("gd4template3d 1.0.0"))
	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)

	maze3d_demo()
	orbit_demo()
	wirenet_demo()
	bartree_demo()
	calendar_demo()
	clock_demo()
	line2d_demo()
	arrow3d_demo()
	valvehandle_demo()
	meshtrail_demo()

	main_animation.animation_ended.connect(main_animation_ended)
	start_all_animation()

func maze3d_demo() -> void:
	var ms := Maze3DSetting.new_default()
	ms.MazeSize = Vector2i(8,5)
	ms.MazeSize += Vector2i(randi_range(-1,1), randi_range(-1,1) )
	ms.StoryH *= pow(2, randf()*2 -1 )
	ms.LaneW = WorldSize.x/ms.MazeSize.x
	$Maze3D.init_with_color(
		ms,
		Callable(),
		random_color(),
		random_color(),
		random_color(),
		)
	$Maze3D.position.x = WorldSize.x/2
	$Maze3D.position.y = -ms.StoryH/2

var b_box :AABB
func meshtrail_demo() -> void:
	var mt = ["♠","♣","♥","♦" ,"★","☆","♩","♪","♬"].pick_random()
	var bound_size = Vector3(WorldSize.x, WorldSize.y, 20)
	b_box = AABB( Vector3(0,0,-10), bound_size)
	var ball = preload("res://mesh_trail/mesh_trail.tscn").instantiate()
	var radius = 0.5
	var count = randi_range(10,20)
	var startpos = b_box.get_center()
	match randi_range(0,3):
		0:
			ball.init_OnBounce().set_get_random_color_fn(random_color)
		1:
			ball.init_MeshGradient().set_get_random_color_fn(random_color)
		2:
			ball.init_ByPosition(b_box)
		3:
			ball.init_ByPositionFn(get_color_ByPosition)
	ball.init( bounce_fn, radius, count, mt, startpos).set_speed(5,10,0.05)
	$DemoContainer.add_child(ball)
func get_color_ByPosition(pos :Vector3) -> Color:
	var co :Color
	for i in 3:
		co[i] = (pos[i] - b_box.position[i]) / b_box.size[i]
	co = co.inverted()
	return co
func bounce_fn(_oldpos:Vector3, pos :Vector3, radius :float) -> Dictionary:
	return Bounce.v3f(pos, b_box, radius)

func arrow3d_demo() -> void:
	$Arrow3D.set_color(random_color()).set_size(5,0.2,0.6)
	$Arrow3D.position = WorldSize/4 + Vector3(0,0,4)

func valvehandle_demo() -> void:
	$ValveHandle.init(2,2,4, random_color())
	$ValveHandle.position = WorldSize *0.75 + Vector3(0,0,4)

func line2d_demo() -> void:
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
	sv.transparent_bg = true
	sv.add_child(l2d)
	add_child(sv)
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	sp.position = WorldSize/2 - Vector3(0,0,0.7)
	sp.material_override = StandardMaterial3D.new()
	sp.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	sp.material_override.albedo_texture = sv.get_texture()
	$DemoContainer.add_child(sp)

func orbit_demo() -> void:
	var diagonal_length = WorldSize.length()/2
	var a120 = PI*2/3
	var a30 = PI/6
	var axis1 = Vector3.UP.rotated(Vector3.RIGHT, a30)
	var os = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate()
	var mat1 = StandardMaterial3D.new()
	mat1.albedo_color = random_color()
	var mat2 = StandardMaterial3D.new()
	mat2.albedo_color = random_color()
	os.궤도설정(diagonal_length*1.1, 1.0/3, axis1, a120*2).구설정(2, 1, Vector3.UP).구재질설정(mat2).궤도재질설정(mat1)
	os.position = WorldSize/2
	$DemoContainer.add_child(os)

func calendar_demo() -> void:
	var ca = preload("res://calendar3d/calendar_3d.tscn").instantiate(
		).init(WorldSize.x/2, WorldSize.y, WorldSize.z, WorldSize.y/2.0 , false )
	ca.rotate_y(PI/2)
	ca.rotate_x(PI/2)
	ca.position = Vector3(WorldSize.x/4,WorldSize.y/2,WorldSize.z/2)
	$DemoContainer.add_child(ca)

func clock_demo() -> void:
	var ca = preload("res://analogclock3d/analog_clock_3d.tscn").instantiate(
		).init(WorldSize.x/4, WorldSize.z, WorldSize.y/2.0 ,9.0, false )
	ca.rotate_y(PI/2)
	ca.rotate_x(PI/2)
	ca.position = Vector3(WorldSize.x/4*3,WorldSize.y/2,WorldSize.z/2)
	$DemoContainer.add_child(ca)

func wirenet_demo() -> void:
	var wn = preload("res://wire_net/wire_net.tscn").instantiate()
	wn.init_with_color(Vector2(40,22), Vector2(41,23), 0.1, random_color())
	$DemoContainer.add_child(wn)

func bartree_demo() -> void:
	var bt = make_tree(WorldSize.x/3, WorldSize.y/3)
	bt.rotate_x(PI/2)
	bt.position = WorldSize/2
	$DemoContainer.add_child(bt)
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
	return NamedColorList.color_list.pick_random()[0]

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
	if camera_move:
		$MovingCameraLight.make_current()
		$MovingCameraLight.move_hober_around_z(WorldSize/2, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )
	main_animation.handle_animation()

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_INSERT:_on_button_fov_up_pressed,
	KEY_DELETE:_on_button_fov_down_pressed,
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

func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_dec()

func reset_camera_pos()->void:
	$FixedCameraLight.make_current()
	$FixedCameraLight.set_center_pos_far(
		WorldSize/2,
		Vector3(WorldSize.x/2, WorldSize.y/2, WorldSize.x),
		WorldSize.length()*2)
