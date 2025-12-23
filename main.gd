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
	start_rotate_animation(arrow3d,
		[Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random(),
		AnimationDuration)
	start_rotate_animation(valvehandle, Vector3.Axis.AXIS_Y, AnimationDuration)


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
	$MovingCameraLightAround.set_center_pos_far( Vector3.ZERO, Vector3(0, 0, WorldSize.z), WorldSize.length()*3)
	$AxisArrow3D.set_colors().set_size(WorldSize.length()/10)

	glass_cabinet_demo()
	bartree_demo($GlassCabinetContainer.get_child(0))
	clock_demo($GlassCabinetContainer.get_child(1))
	calendar_demo($GlassCabinetContainer.get_child(2))
	orbit_demo($GlassCabinetContainer.get_child(3))
	line2d_demo($GlassCabinetContainer.get_child(4))
	meshtrail_demo($GlassCabinetContainer.get_child(5))
	maze3d_demo($GlassCabinetContainer.get_child(6))
	reel_demo($GlassCabinetContainer.get_child(7))
	wheel_demo($GlassCabinetContainer.get_child(8))
	valvehandle_demo($GlassCabinetContainer.get_child(10))
	arrow3d_demo($GlassCabinetContainer.get_child(10))
	wirenet_demo($GlassCabinetContainer.get_child(11))
	wavegauge_demo($GlassCabinetContainer.get_child(11))

	$MovingCameraLightAround.make_current()
	main_animation.animation_ended.connect(main_animation_ended)
	start_all_animation()

func glass_cabinet_demo() -> void:
	var count := 24
	var unit_rad := 2*PI/ count
	for i in count:
		var radius := WorldSize.length() *1.7
		var gc :GlassCabinet = preload("res://glass_cabinet/glass_cabinet.tscn").instantiate(
			).init(WorldSize - Vector3(1,1,1) )
		$GlassCabinetContainer.add_child(gc)
		var rad := i * unit_rad
		if i % 2 == 0:
			gc.position = Vector3(sin(rad)*radius, WorldSize.y/2 *1.0, cos(rad)*radius)
		else:
			gc.position = Vector3(sin(rad)*radius, -WorldSize.y/2 *1.0, cos(rad)*radius)
		gc.look_at( Vector3(0,gc.position.y,0), Vector3.UP, true)
		gc.set_label_text("%d" % i).show_label(true)


var colorlist_dark :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_dark_color_list())
var colorlist_light :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_light_color_list())
var cardlist :Array = PlayingCard.make_deck_with_joker()
func make_color_text_info_list(colist :Array, cdlist :Array) -> Array:
	var rtn := []
	for i in cdlist.size():
		rtn.append( [ colist[i%colist.size()], cdlist[i] ] )
	return rtn

var roulette :Roulette
func wheel_demo(glasscabinet :GlassCabinet) -> void:
	var color_text_into_list := make_color_text_info_list(
		colorlist_light, cardlist,
	).duplicate()
	color_text_into_list.shuffle()
	roulette = preload("res://roulette/roulette.tscn").instantiate(
		).init(0, WorldSize.y/2, WorldSize.z/20, color_text_into_list )
	roulette.색설정하기(make_random_color(), make_random_color(), make_random_color() )
	roulette.rotation_stopped.connect(wheel결과가결정됨)
	glasscabinet.add_child(roulette)
	wheel돌리기()
func make_random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]
func wheel돌리기() -> void:
	var rot = randfn(2*PI, PI/2)
	if randi_range(0,1) == 0:
		rot = -rot
	roulette.돌리기시작.call_deferred(rot)
func wheel결과가결정됨(rl :Roulette) -> void:
	$"왼쪽패널/LabelWheel".text = rl.선택된cell얻기().글내용얻기()
	$TimerWheel.start()
func _on_timer_wheel_timeout() -> void:
	wheel돌리기()

var slotreel :SlotReel
func reel_demo(glasscabinet :GlassCabinet) -> void:
	var symbol크기 := Vector2(WorldSize.x/15 ,WorldSize.y/15)
	var color_text_into_list := make_color_text_info_list(colorlist_dark, cardlist).duplicate()
	color_text_into_list.shuffle()
	slotreel = preload("res://slot_reel/slot_reel.tscn").instantiate(
		).init(0, symbol크기, color_text_into_list)
	slotreel.rotation_stopped.connect(reel결과가결정됨)
	glasscabinet.add_child(slotreel)
	reel돌리기()
func reel돌리기() -> void:
	var rot = randfn(2*PI, PI/2)
	if randi_range(0,1) == 0:
		rot = -rot
	slotreel.돌리기시작(rot)
func reel결과가결정됨( rl :SlotReel) -> void:
	$"왼쪽패널/LabelReel".text = rl.선택된symbol얻기().글내용얻기()
	$TimerReel.start()
func _on_timer_reel_timeout() -> void:
	reel돌리기()

var wavegauge :WaveGauge
var grid_size := Vector2i(16,9)*2
func wavegauge_demo(glasscabinet :GlassCabinet) -> void:
	wavegauge = preload("res://wave_gauge/wave_gauge.tscn").instantiate(
		).init(Vector3(WorldSize.x,WorldSize.y,WorldSize.z/20), Vector3i(grid_size.x,grid_size.y,1), WaveGauge.color_list, 0.1, 1.0 )
	glasscabinet.add_child(wavegauge)

var wirenet :MultiMeshShape
func wirenet_demo(glasscabinet :GlassCabinet) -> void:
	wirenet = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate(
		).init_wire_net(Vector2(WorldSize.x,WorldSize.y), Vector2i(grid_size.x+1,grid_size.y+1), WorldSize.x/grid_size.x/10, random_color())
	#$WireNet.position = base_pos
	glasscabinet.add_child(wirenet)

var maze3d :Maze3D
func maze3d_demo(glasscabinet :GlassCabinet) -> void:
	var ms := Maze3DSetting.new_default()
	ms.MazeSize = Vector2i(16,9)
	ms.LaneW = WorldSize.x/ms.MazeSize.x
	ms.StoryH = ms.LaneW
	ms.WallThick = ms.LaneW *0.1
	ms.MakeSubWallRate = 0.1
	maze3d = preload("res://maze_3d/maze_3d.tscn").instantiate(
		).init_with_color( ms, Callable(), random_color(), random_color(), random_color() )
	maze3d.rotation.x = PI/2
	glasscabinet.add_child(maze3d)

var meshtrail :MeshTrail
var bound_aabb :AABB
var trailmesh_radius := WorldSize.length()/100
func meshtrail_demo(glasscabinet :GlassCabinet) -> void:
	bound_aabb = AABB( -WorldSize/2, WorldSize)
	var count := 100
	var startpos := bound_aabb.get_center()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(trailmesh_radius*3, trailmesh_radius /5, trailmesh_radius/5)
	meshtrail = preload("res://mesh_trail/mesh_trail.tscn").instantiate(
		).init_with_alpha(mesh, count,  1.0 , startpos,
		).set_speed(trailmesh_radius*20,trailmesh_radius*40)
	glasscabinet.add_child(meshtrail)
	match randi_range(0,3):
		0:
			meshtrail.set_ColorChange_OnBounce()
		1:
			meshtrail.set_ColorChange_MeshGradient()
		2:
			meshtrail.set_ColorChange_ByPosition(bound_aabb)
		3:
			meshtrail.set_ColorChange_ByPositionFn(get_color_ByPosition)
func get_color_ByPosition(pos :Vector3) -> Color:
	var co :Color
	for i in 3:
		co[i] = (pos[i] - bound_aabb.position[i]) / bound_aabb.size[i]
	co = co.inverted()
	return co
func bounce_fn(_oldpos:Vector3, pos :Vector3, radius :float) -> Dictionary:
	return Bounce.v3f(pos, bound_aabb, radius)

var arrow3d :Arrow3D
func arrow3d_demo(glasscabinet :GlassCabinet) -> void:
	arrow3d = preload("res://arrow3d/arrow_3d.tscn").instantiate(
		).set_color(random_color()).set_size( WorldSize.x/10, WorldSize.x/100, WorldSize.x/50)
	#$Arrow3D.position = base_pos
	glasscabinet.add_child(arrow3d)

var valvehandle :ValveHandle
func valvehandle_demo(glasscabinet :GlassCabinet) -> void:
	valvehandle = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(WorldSize.x/20,WorldSize.x/20,4, random_color())
	#valvehandle.position = base_pos
	glasscabinet.add_child(valvehandle)

func line2d_demo(glasscabinet :GlassCabinet) -> void:
	var size_pixel := Vector2i(2048,2048)
	var ml2d = preload("res://move_line2d/move_line_2d.tscn").instantiate()
	ml2d.init_with_random(300, 4, 1, size_pixel)
	ml2d.start()
	var svp = SubViewport.new()
	svp.add_child(ml2d)
	svp.size = size_pixel
	svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	svp.transparent_bg = true
	var ml2dmi = MeshInstance3D.new()
	ml2dmi.mesh = PlaneMesh.new()
	ml2dmi.mesh.size = Vector2(WorldSize.x, WorldSize.y)
	ml2dmi.mesh.orientation = PlaneMesh.FACE_Z
	ml2dmi.material_override = StandardMaterial3D.new()
	ml2dmi.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	ml2dmi.material_override.albedo_texture = svp.get_texture()
	glasscabinet.add_child(svp)
	glasscabinet.add_child(ml2dmi)

var orbitsphere :OrbitSphere
func orbit_demo(glasscabinet :GlassCabinet) -> void:
	var diagonal_length := WorldSize.length()/2
	var a120 := PI*2/3
	var a30 := PI/6
	var axis1 := Vector3.UP.rotated(Vector3.RIGHT, a30)
	var mat1 := StandardMaterial3D.new()
	mat1.albedo_color = random_color()
	var mat2 := StandardMaterial3D.new()
	mat2.albedo_color = random_color()
	orbitsphere = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate(
		).궤도설정(diagonal_length, diagonal_length/200, axis1, a120*2).구설정(WorldSize.x/40, WorldSize.x/50, Vector3.UP).구재질설정(mat2).궤도재질설정(mat1)
	glasscabinet.add_child(orbitsphere)

var calendar :Calendar3D
func calendar_demo(glasscabinet :GlassCabinet) -> void:
	calendar = preload("res://calendar3d/calendar_3d.tscn").instantiate(
		).init(WorldSize.x/2, WorldSize.y, WorldSize.z/10, WorldSize.y/2.0/6 , false )
	calendar.rotate_y(PI/2)
	calendar.rotate_x(PI/2)
	glasscabinet.add_child(calendar)

var clock :AnalogClock3D
func clock_demo(glasscabinet :GlassCabinet) -> void:
	clock = preload("res://analogclock3d/analog_clock_3d.tscn").instantiate(
		).init(WorldSize.x/4, WorldSize.z/10, WorldSize.y/2.0/7 ,9.0, false )
	clock.rotate_y(PI/2)
	clock.rotate_x(PI/2)
	glasscabinet.add_child(clock)

var bartree :BarTree2
func bartree_demo(glasscabinet :GlassCabinet) -> void:
	var tree_size := Vector3(WorldSize.x/3, WorldSize.y/3, WorldSize.x/3 * randf_range(0.5 , 2.0)/10)
	var bar_count := randf_range(5,200)
	bartree = preload("res://bar_tree_2/bar_tree_2.tscn").instantiate(
		).init_bartree_with_color(random_color(), random_color(),bar_count
		).init_bartree_transform(tree_size, 0)
	glasscabinet.add_child(bartree)
func random_color()->Color:
	return NamedColorList.color_list.pick_random()[0]


func _process(delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	label_demo()
	wavegauge.animate_wave(now)
	roulette.장식돌리기()
	roulette.선택된cell강조상태켜기()
	bartree.rotate_tree_bar_y(delta*10)
	orbitsphere.animate_rotate(now, delta)
	meshtrail.move_trail(delta, bounce_fn, trailmesh_radius, 4*PI,)

	main_animation.handle_animation()
	var t := now /2.3
	if $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(t, Vector3.ZERO, WorldSize.length()/4, WorldSize.length()/10 )

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
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()
