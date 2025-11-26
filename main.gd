extends Node3D

const WorldSize := Vector3(40,22,20)
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
	$OmniLight3D.position = WorldSize/2 + Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2
	$FixedCameraLight.set_center_pos_far(
		WorldSize/2,
		Vector3(WorldSize.x/2, WorldSize.y/2, WorldSize.x),
		WorldSize.length()*2)

	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect,
		"%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version")
			] )

	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)

	$AxisArrow3D.set_size(10)
	bargauge_demo()
	wallbox_demo()
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

var gauge_list :Array
func bargauge_demo() -> void:
	for i in WorldSize.x:
		var irate = float(i) / WorldSize.x
		var bg = preload("res://bar_gauge/bar_gauge.tscn").instantiate().init(
			WorldSize.y,
			Vector3(1, WorldSize.y, 1),
			lerp(Color.GREEN, Color.BLUE, irate),
			lerp(Color.RED, Color.YELLOW, irate),
			)
		bg.position = Vector3(0.5+i, 0.5, 0.5 -WorldSize.z/2)
		gauge_list.append(bg)
		add_child(bg)

func wallbox_demo() -> void:
	$WallBox.mesh.size = WorldSize #+ Vector3(1,1,5)
	$WallBox.position = WorldSize/2 + Vector3(0,0,-WorldSize.z/2)
	$WallBox.mesh.material.albedo_color = Color(random_color(), 0.5)

func maze3d_demo() -> void:
	var ms := Maze3DSetting.new_default()
	ms.MazeSize = Vector2i(8,5)
	ms.MazeSize += Vector2i(randi_range(-1,1), randi_range(-1,1) )
	ms.StoryH = WorldSize.y /4
	ms.LaneW = WorldSize.x/ms.MazeSize.x
	$Maze3D.init_with_color(
		ms,
		Callable(),
		random_color(),
		random_color(),
		random_color(),
		)
	$Maze3D.position.x = WorldSize.x/2
	$Maze3D.position.y = -ms.StoryH

var b_box :AABB
func meshtrail_demo() -> void:
	var mt = ["♠","♣","♥","♦" ,"★","☆","♩","♪","♬"].pick_random()
	var bound_size = WorldSize # Vector3(WorldSize.x, WorldSize.y, 20)
	b_box = AABB( Vector3(0,0,-WorldSize.z/2), bound_size)
	var ball = preload("res://mesh_trail/mesh_trail.tscn").instantiate()
	var radius = 1.0
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
	$Arrow3D.position = Vector3(WorldSize.x/4, WorldSize.y/4, WorldSize.z/4)

func valvehandle_demo() -> void:
	$ValveHandle.init(2,2,4, random_color())
	$ValveHandle.position = Vector3(WorldSize.x*3/4, WorldSize.y/4, WorldSize.z/4)

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
	sp.position = WorldSize/2 + Vector3(0,0,-1.0)
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
		).init(WorldSize.x/2, WorldSize.y, 2, WorldSize.y/2.0 , false )
	ca.rotate_y(PI/2)
	ca.rotate_x(PI/2)
	ca.position = Vector3(WorldSize.x/4,WorldSize.y/2,0)
	$DemoContainer.add_child(ca)

func clock_demo() -> void:
	var ca = preload("res://analogclock3d/analog_clock_3d.tscn").instantiate(
		).init(WorldSize.x/4, 2, WorldSize.y/2.0 ,9.0, false )
	ca.rotate_y(PI/2)
	ca.rotate_x(PI/2)
	ca.position = Vector3(WorldSize.x/4*3,WorldSize.y/2,0)
	$DemoContainer.add_child(ca)

func wirenet_demo() -> void:
	var wn = preload("res://wire_net/wire_net.tscn").instantiate()
	wn.init_with_color(Vector2(40,22), Vector2(41,23), 0.1, random_color())
	wn.position.z = -WorldSize.z/2 +1
	$DemoContainer.add_child(wn)

func bartree_demo() -> void:
	var bt = make_tree(WorldSize.x/3, WorldSize.y/3)
	bt.rotate_x(PI/2)
	bt.position = WorldSize/2 + Vector3(0,0,-WorldSize.z+2)
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

func label_demo() -> void:
	if $"오른쪽패널/LabelPerformance".visible:
		$"오른쪽패널/LabelPerformance".text = """%d FPS (%.2f mspf)
Currently rendering: occlusion culling:%s
%d objects
%dK primitive indices
%d draw calls""" % [
		Engine.get_frames_per_second(),1000.0 / Engine.get_frames_per_second(),
		get_tree().root.use_occlusion_culling,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		]
	if $"오른쪽패널/LabelInfo".visible:
		$"오른쪽패널/LabelInfo".text = "%s" % [ MovingCameraLight.GetCurrentCamera() ]

func on_viewport_size_changed():
	pass

func message_hidden(_s :String) -> void:
	pass

func _process(_delta: float) -> void:
	label_demo()
	for bg in gauge_list:
		bg.inc_current_value([-1,1].pick_random())
	main_animation.handle_animation()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(WorldSize/2, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_around_y(WorldSize/2, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()

func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_dec()

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
