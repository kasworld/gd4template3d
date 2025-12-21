extends Node3D

const WorldSize := Vector3(160,90,80)

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


func timed_message_init() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var msgrect := Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect,
		"%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version")
			] )
	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)
func message_hidden(_s :String) -> void:
	pass


func ui_panel_init() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var 짧은길이 :float = min(vp_size.x, vp_size.y)
	var panel_size := Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$"왼쪽패널".size = panel_size
	$"왼쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.size = panel_size
	$"오른쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
func on_viewport_size_changed():
	ui_panel_init()

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


func _ready() -> void:
	get_viewport().size_changed.connect(on_viewport_size_changed)
	ui_panel_init()
	timed_message_init()
	$OmniLight3D.position = Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, 	Vector3(0, 0, WorldSize.z*2), WorldSize.length()*2)
	$MovingCameraLightHober.set_center_pos_far( Vector3.ZERO, Vector3(0, 0, WorldSize.z), WorldSize.length()*2)
	$MovingCameraLightAround.set_center_pos_far( Vector3.ZERO, Vector3(0, 0, WorldSize.z), WorldSize.length()*2)
	$AxisArrow3D.set_size(10)

	wallbox_demo(Vector3.ZERO)
	bartree_demo(Vector3(0, -WorldSize.y/2, 0 ))
	wirenet_demo(Vector3(-WorldSize.x/2, -WorldSize.y/2, -WorldSize.z/2 +1))
	clock_demo(Vector3(WorldSize.x/4,0,WorldSize.z/4 +1))
	calendar_demo(Vector3(-WorldSize.x/4,0,WorldSize.z/4 -1))
	orbit_demo(Vector3.ZERO)
	line2d_demo(Vector3(0,0,WorldSize.z/2-1.0))
	valvehandle_demo(Vector3(WorldSize.x/4, -WorldSize.y/4, 0))
	arrow3d_demo(Vector3(-WorldSize.x/4, -WorldSize.y/4, 0))
	meshtrail_demo(Vector3.ZERO)
	maze3d_demo( Vector3(0, -WorldSize.y/2 ,0) )
	wavegauge_demo(Vector3(0, 0 , -WorldSize.z/2))
	reel_demo(Vector3( WorldSize.x/2 , 0, 0))
	wheel_demo(Vector3( -WorldSize.x/2 - 2, 0,0))

	main_animation.animation_ended.connect(main_animation_ended)
	start_all_animation()

var colorlist_dark :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_dark_color_list())
var colorlist_light :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_light_color_list())
var cardlist :Array = PlayingCard.make_deck_with_joker()
func make_color_text_info_list(colist :Array, cdlist :Array) -> Array:
	var rtn := []
	for i in cdlist.size():
		rtn.append( [ colist[i%colist.size()], cdlist[i] ] )
	return rtn


func wheel_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var color_text_into_list := make_color_text_info_list(
		colorlist_light, cardlist,
	).duplicate()
	color_text_into_list.shuffle()
	$Roulette.init(0, WorldSize.y/2, 0.5, color_text_into_list )
	$Roulette.색설정하기(make_random_color(), make_random_color(), make_random_color() )
	$Roulette.rotation_stopped.connect(wheel결과가결정됨)
	$Roulette.position = base_pos
	wheel돌리기()
func make_random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]
func wheel돌리기() -> void:
	var rot = randfn(2*PI, PI/2)
	if randi_range(0,1) == 0:
		rot = -rot
	$Roulette.돌리기시작.call_deferred(rot)
func wheel결과가결정됨(rl :Roulette) -> void:
	$"왼쪽패널/LabelWheel".text = rl.선택된cell얻기().글내용얻기()
	$TimerWheel.start()
func _on_timer_wheel_timeout() -> void:
	wheel돌리기()


func reel_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var symbol크기 := Vector2(WorldSize.x/15 ,WorldSize.y/15)
	var color_text_into_list := make_color_text_info_list(
		colorlist_dark, cardlist,
	).duplicate()
	color_text_into_list.shuffle()
	$SlotReel.init(0, symbol크기, color_text_into_list)
	$SlotReel.rotation_stopped.connect(reel결과가결정됨)
	$SlotReel.position = base_pos + Vector3(symbol크기.x,0,0)
	reel돌리기()
func reel돌리기() -> void:
	var rot = randfn(2*PI, PI/2)
	if randi_range(0,1) == 0:
		rot = -rot
	$SlotReel.돌리기시작(rot)
func reel결과가결정됨( rl :SlotReel) -> void:
	$"왼쪽패널/LabelReel".text = rl.선택된symbol얻기().글내용얻기()
	$TimerReel.start()
func _on_timer_reel_timeout() -> void:
	reel돌리기()


func wavegauge_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var wavegauge_size := WorldSize
	wavegauge_size.z = 1
	$WaveGauge.init(wavegauge_size, Vector3i(wavegauge_size), WaveGauge.color_list, 0.1, 1.0 )
	$WaveGauge.position = base_pos

func wallbox_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	$WallBox.mesh.size = WorldSize
	$WallBox.position = base_pos
	$WallBox.mesh.material.albedo_color = Color(random_color(), 0.5)

func maze3d_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var ms := Maze3DSetting.new_default()
	ms.MazeSize = Vector2i(16,9)
	ms.LaneW = WorldSize.x/ms.MazeSize.x
	ms.StoryH = ms.LaneW
	$Maze3D.init_with_color( ms, Callable(), random_color(), random_color(), random_color() )
	$Maze3D.position = base_pos + Vector3(0, -ms.StoryH,0)


var bound_aabb :AABB
var trailmesh_radius := 1.0
func meshtrail_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	bound_aabb = AABB( base_pos -WorldSize/2, WorldSize)
	var count := 20
	var startpos := bound_aabb.get_center()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(trailmesh_radius*2, trailmesh_radius*2, 0.1)
	$MeshTrail.init_with_alpha(mesh, count,  1.0 , startpos,
		).set_speed(20,40)
	match randi_range(0,3):
		0:
			$MeshTrail.set_ColorChange_OnBounce()
		1:
			$MeshTrail.set_ColorChange_MeshGradient()
		2:
			$MeshTrail.set_ColorChange_ByPosition(bound_aabb)
		3:
			$MeshTrail.set_ColorChange_ByPositionFn(get_color_ByPosition)
func get_color_ByPosition(pos :Vector3) -> Color:
	var co :Color
	for i in 3:
		co[i] = (pos[i] - bound_aabb.position[i]) / bound_aabb.size[i]
	co = co.inverted()
	return co
func bounce_fn(_oldpos:Vector3, pos :Vector3, radius :float) -> Dictionary:
	return Bounce.v3f(pos, bound_aabb, radius)


func arrow3d_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	$Arrow3D.set_color(random_color()).set_size( WorldSize.x/10, WorldSize.x/100, WorldSize.x/50)
	$Arrow3D.position = base_pos

func valvehandle_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	$ValveHandle.init(WorldSize.x/20,WorldSize.x/20,4, random_color())
	$ValveHandle.position = base_pos

func line2d_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var size_pixel := Vector2i(2048,2048)
	$MoveLine2DSubViewport/MoveLine2D.init_with_random(300, 4, 1, size_pixel)
	$MoveLine2DSubViewport/MoveLine2D.start()
	$MoveLine2DSubViewport.size = size_pixel
	$MoveLine2DSubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	$MoveLine2DSubViewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	$MoveLine2DSubViewport.transparent_bg = true
	$MoveLine2DMeshInstance3D.mesh = PlaneMesh.new()
	$MoveLine2DMeshInstance3D.mesh.size = Vector2(WorldSize.x, WorldSize.y)
	$MoveLine2DMeshInstance3D.mesh.orientation = PlaneMesh.FACE_Z
	$MoveLine2DMeshInstance3D.position = base_pos
	$MoveLine2DMeshInstance3D.material_override = StandardMaterial3D.new()
	$MoveLine2DMeshInstance3D.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	$MoveLine2DMeshInstance3D.material_override.albedo_texture = $MoveLine2DSubViewport.get_texture()

func orbit_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var diagonal_length := WorldSize.length()/2
	var a120 := PI*2/3
	var a30 := PI/6
	var axis1 := Vector3.UP.rotated(Vector3.RIGHT, a30)
	var mat1 := StandardMaterial3D.new()
	mat1.albedo_color = random_color()
	var mat2 := StandardMaterial3D.new()
	mat2.albedo_color = random_color()
	$OrbitSphere.궤도설정(diagonal_length*1.1, 1.0/3, axis1, a120*2).구설정(WorldSize.x/40, WorldSize.x/50, Vector3.UP).구재질설정(mat2).궤도재질설정(mat1)
	$OrbitSphere.position = base_pos

func calendar_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	$Calendar3d.init(WorldSize.x/2, WorldSize.y, 2, WorldSize.y/2.0/6 , false )
	$Calendar3d.rotate_y(PI/2)
	$Calendar3d.rotate_x(PI/2)
	$Calendar3d.position = base_pos

func clock_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	$AnalogClock3d.init(WorldSize.x/4, 2, WorldSize.y/2.0/7 ,9.0, false )
	$AnalogClock3d.rotate_y(PI/2)
	$AnalogClock3d.rotate_x(PI/2)
	$AnalogClock3d.position = base_pos

func wirenet_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	$WireNet.init_wire_net(Vector2(WorldSize.x,WorldSize.y), Vector2i(WorldSize.x-1,WorldSize.y-1), 0.1, random_color())
	$WireNet.position = base_pos

func bartree_demo(base_pos :Vector3 = Vector3.ZERO) -> void:
	var tree_size := Vector3(WorldSize.x/3, WorldSize.y/3, WorldSize.x/3 * randf_range(0.5 , 2.0)/10)
	var bar_count := randf_range(5,200)
	$BarTree2.init_bartree_with_color(random_color(), random_color(),bar_count
		).init_bartree_transform(tree_size, 0)
	$BarTree2.position = base_pos
func random_color()->Color:
	return NamedColorList.color_list.pick_random()[0]


func _process(delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	label_demo()
	$WaveGauge.animate_wave(now)
	$Roulette.장식돌리기()
	$Roulette.선택된cell강조상태켜기()
	$BarTree2.rotate_tree_bar_y(delta*10)
	$OrbitSphere.animate_rotate(now, delta)
	$MeshTrail.move_trail(delta, bounce_fn, trailmesh_radius, 4*PI,)

	main_animation.handle_animation()
	var t := now /2.3
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(t, Vector3.ZERO, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(t, Vector3.ZERO, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()

func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_dec()

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_PAGEUP:_on_button_fov_up_pressed,
	KEY_PAGEDOWN:_on_button_fov_down_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)

	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()
