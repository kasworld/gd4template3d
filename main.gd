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
	if arrow3d != null:
		start_rotate_animation(arrow3d,
			[Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random(),
			AnimationDuration)
	if valvehandle != null:
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
	$CenterCameraLight.set_center_pos_far( Vector3(0, 0, -WorldSize.z), Vector3.ZERO, WorldSize.length()*3)
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightHober.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightAround.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$AxisArrow3D.set_colors().set_size(WorldSize.length()/20)

	make_glass_cabinet()
	setup_demo_to_cabinet()
	$CenterCameraLight.make_current()
	main_animation.animation_ended.connect(main_animation_ended)
	start_all_animation()

var demo_name_to_glass_cabinet := {}
func setup_demo_to_cabinet() -> void:
	bartree_demo(glass_cabinet_list.pop_front(), "bartree")
	clock_demo(glass_cabinet_list.pop_front(), "clock3d")
	calendar_demo(glass_cabinet_list.pop_front(), "calender3d")
	orbit_demo(glass_cabinet_list.pop_front(), "orbit")
	line2d_demo(glass_cabinet_list.pop_front(), "moveline2d")
	meshtrail_demo(glass_cabinet_list.pop_front(), "meshtrail")
	maze3d_demo(glass_cabinet_list.pop_front(), "maze3d")
	slotreel_demo(glass_cabinet_list.pop_front(), "slotreel")
	wheel_demo(glass_cabinet_list.pop_front(), "roulettewheel" )
	valvehandle_arrow3d_demo(glass_cabinet_list.pop_front(), "valvehandle,arrow3d")
	wirenet_wavegauge_demo(glass_cabinet_list.pop_front(), "wirenet,wavegauge")
	wavegauge_demo(glass_cabinet_list.pop_front(), "wavegauge")
	tornado_demo(glass_cabinet_list.pop_front(), "tornado")
	turbine_tree_demo(glass_cabinet_list.pop_front(), "turbinetree")
	print_debug("remain glass cabinet %d\ndemo size %s" % [
		glass_cabinet_list.size(),demo_name_to_glass_cabinet.size()])


var glass_cabinet_list :Array
func make_glass_cabinet() -> void:
	var count := 24
	var unit_rad := 2*PI/ count
	for i in count:
		var radius := WorldSize.length() *1.7
		var gc :GlassCabinet = preload("res://glass_cabinet/glass_cabinet.tscn").instantiate(
			).init(WorldSize - Vector3(1,1,1) )
		var rad := i * unit_rad
		if i % 2 == 0:
			gc.position = Vector3(sin(rad)*radius, WorldSize.y/2 *1.0, cos(rad)*radius)
			$GlassCabinetContainer1.add_child(gc)
		else:
			gc.position = Vector3(sin(rad)*radius, -WorldSize.y/2 *1.0, cos(rad)*radius)
			$GlassCabinetContainer2.add_child(gc)
		gc.look_at( Vector3(0,gc.position.y,0), Vector3.UP, true)
		gc.set_label_text("%d" % i).show_label(true)
		glass_cabinet_list.append(gc)


func random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]

var centertree :Turbine
var sidetree_list :Array
func turbine_tree_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	#centertree = preload("res://turbine/turbine.tscn").instantiate(
		#).init_basic(WorldSize.y, WorldSize.z/6, 1, 4
		#).set_transform_all(scale_tree, Turbine.shift_zero, Turbine.rotate_zero,
		#).set_color_all(random_color(),random_color())
	#glasscabinet.add_child(centertree)
	#centertree.rotation.x = PI/2
	var tree_size := Vector3(WorldSize.z, WorldSize.y, WorldSize.z / 30)
	var bar_count :int = WorldSize.y
	var pos := Vector3(0.0,-WorldSize.y/2,0.0)
	for i in 12:
		var t = make_sub_tree_2(glasscabinet, tree_size, bar_count, 0.1 *i , pos)
		t.rotation.y = PI/4 * i
		t.rotate_tree_bar_y(PI*7)

func scale_tree(rate):
	return Vector3(rate,rate,1)
func make_sub_tree_2(glasscabinet :GlassCabinet, tree_size :Vector3, bar_count :int, shift :float, pos :Vector3) -> BarTree:
	var t = bartree_scene.instantiate()
	glasscabinet.add_child(t)
	t.position = pos
	t.init_bartree_with_color(random_color(), random_color(), bar_count)
	t.init_bartree_transform(tree_size, shift)
	sidetree_list.append(t)
	return t
func animate_turbine_tree(delta :float) -> void:
	return
	for bt in sidetree_list:
		bt.rotate_tree_bar_y(delta*10)

var tornado_list :Array # [ turbine , colorinfo ]
func tornado_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	glasscabinet.show_wall_box(false)
	for i in 4:
		var tb = preload("res://turbine/turbine.tscn").instantiate(
			).init_sample(WorldSize.x/2, WorldSize.y*0.3, 0.5, 4, random_color(),random_color())
		glasscabinet.add_child(tb)
		tb.rotation.x = -PI/2
		tornado_list.append([tb, AnimateGradient.new()])

func scale_lambda(t :float) -> Callable:
	return func(rate):
		var x = (cos(rate*PI*2 + t)+2) * (rate/4+0.25)
		var y = (sin(rate*PI*2 + t)+2) * (rate/4+0.25)
		return Vector3(x,y,1)
func shift_lambda(t :float) -> Callable:
	return func(rate):
		return Vector3(cos(t), sin(t), 0) * rate * WorldSize.x/5
func rotate_lambda(t :float) -> Callable:
	return func(rate):
		return 2*PI*rate*t

func scale_tornado(rate):
	return Vector3(rate,rate,1)*rate
func shift_tornado_lambda(t :float) -> Callable:
	return func(rate):
		var period := 5
		return Vector3(cos(rate*period), sin(rate*period), 0) * t * WorldSize.x/10

func tornado_animate() -> void:
	var t := Time.get_unix_time_from_system()
	var rad := fposmod(t, PI*2)
	var unit_rad := 2*PI/4
	var radius := WorldSize.z/2
	for i in tornado_list.size():
		var tt := t+ i
		tornado_list[i][0].set_transform_all(scale_tornado, shift_tornado_lambda( sin(tt) ), rotate_lambda( sin(tt) ),Turbine.blade_rotate_lambda(rad/PI/2))
		tornado_list[i][0].set_color_all(tornado_list[i][1].get_color1(),tornado_list[i][1].get_color2())
		tornado_list[i][1].inc_rate()
		tornado_list[i][0].position = Vector3(cos(i*unit_rad+t)*radius, sin(i*unit_rad+t*1.7)*radius/2, sin(i*unit_rad+t)*radius)
		tornado_list[i][0].rotation.y = -rad*5


var colorlist_dark :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_dark_color_list())
var colorlist_light :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_light_color_list())
var cardlist :Array = PlayingCard.make_deck_with_joker()
func make_color_text_info_list(colist :Array, cdlist :Array) -> Array:
	var rtn := []
	for i in cdlist.size():
		rtn.append( [ colist[i%colist.size()], cdlist[i] ] )
	return rtn

var roulette :Roulette
func wheel_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
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

var slot :Slots
func slotreel_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	var symbol크기 := Vector2(WorldSize.x/20 ,WorldSize.y/20)
	var color_text_into_list := make_color_text_info_list(colorlist_dark, cardlist).duplicate()
	slot = preload("res://slots/slots.tscn").instantiate().init(5, symbol크기,color_text_into_list)
	glasscabinet.add_child(slot)
	slot.rotation_stopped.connect(슬롯멈춤)
	slot.돌리기시작()
func 슬롯멈춤(sl :Slots) -> void:
	var symbol들 := sl.선택된symbol들얻기()
	var 결과 := ""
	for k in symbol들:
		결과 += k.글내용얻기() + " "
	$"왼쪽패널/LabelReel".text = 결과
	$TimerReel.start()
func _on_timer_reel_timeout() -> void:
	slot.돌리기시작()


var wavegauge_box :WaveGauge
func wavegauge_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	wavegauge_box = preload("res://wave_gauge/wave_gauge.tscn").instantiate(
		).init(Vector3(WorldSize.x-1,WorldSize.y-1,WorldSize.z-1), Vector3i(32,32,32), WaveGauge.color_list, 0.1, 1.0 )
	glasscabinet.add_child(wavegauge_box)

var wirenet :MultiMeshShape
var wavegauge_plane :WaveGauge
func wirenet_wavegauge_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	var grid_size := Vector2i(16,9)*2
	wirenet = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate(
		).init_wire_net(Vector2(WorldSize.x,WorldSize.y), Vector2i(grid_size.x,grid_size.y), WorldSize.x/grid_size.x/10, random_color())
	glasscabinet.add_child(wirenet)
	wavegauge_plane = preload("res://wave_gauge/wave_gauge.tscn").instantiate(
		).init(Vector3(WorldSize.x,WorldSize.y,WorldSize.z/20), Vector3i(grid_size.x,grid_size.y,1), WaveGauge.color_list, 0.1, 1.0 )
	glasscabinet.add_child(wavegauge_plane)

var maze3d :Maze3D
func maze3d_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	var ms := Maze3DSetting.new_default()
	ms.MazeSize = Vector2i(16,9)
	ms.LaneW = WorldSize.x/ms.MazeSize.x-0.1
	ms.StoryH = ms.LaneW
	ms.WallThick = ms.LaneW *0.1
	ms.MakeSubWallRate = 0.1
	maze3d = preload("res://maze_3d/maze_3d.tscn").instantiate(
		).init_with_color( ms, Callable(), random_color(), random_color(), random_color() )
	maze3d.rotation.x = PI/4
	maze3d.view_floor_ceiling(false,false)
	glasscabinet.add_child(maze3d)

var meshtrail_list :Array
var bound_aabb :AABB
var trailmesh_radius := WorldSize.length()/100
func meshtrail_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	bound_aabb = AABB( -WorldSize/2, WorldSize)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(trailmesh_radius*3, trailmesh_radius /5, trailmesh_radius/5)
	for i in 10:
		make_meshtrail(glasscabinet, randi_range(0,4), mesh, 100, bound_aabb.get_center())
func make_meshtrail(glasscabinet :GlassCabinet, mt_type:int, mesh :Mesh, count :int, pos :Vector3 ) -> void:
	var mt = preload("res://mesh_trail/mesh_trail.tscn").instantiate(
		).init_with_alpha(mesh, count,  1.0 ,true, pos,
		).set_speed(trailmesh_radius*20,trailmesh_radius*40)
	glasscabinet.add_child(mt)
	meshtrail_list.append(mt)
	match mt_type:
		0:
			mt.set_ColorChange_OnBounce()
		1:
			mt.set_ColorChange_MeshGradient()
		2:
			mt.set_ColorChange_ByPosition(bound_aabb)
		3:
			mt.set_ColorChange_ByPositionFn(get_color_ByPosition)
func get_color_ByPosition(pos :Vector3) -> Color:
	var co :Color
	for i in 3:
		co[i] = (pos[i] - bound_aabb.position[i]) / bound_aabb.size[i]
	co = co.inverted()
	return co
func bounce_fn(_oldpos:Vector3, pos :Vector3, radius :float) -> Dictionary:
	return Bounce.v3f(pos, bound_aabb, radius)

var arrow3d :Arrow3D
var valvehandle :ValveHandle
func valvehandle_arrow3d_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	glasscabinet.show_axis_arrow()
	arrow3d = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(random_color()).set_size( WorldSize.x/5, WorldSize.x/50, WorldSize.x/25)
	arrow3d.position = Vector3(WorldSize.x/4, 0,0)
	glasscabinet.add_child(arrow3d)
	valvehandle = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(WorldSize.x/10,WorldSize.x/10,4, random_color())
	valvehandle.position = Vector3(-WorldSize.x/4, 0,0)
	glasscabinet.add_child(valvehandle)


func line2d_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	glasscabinet.show_wall_box(false)
	var size_pixel := Vector2i(2048,2048)
	var ml2d = preload("res://move_line_2d/move_line_2d.tscn").instantiate()
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
	#ml2dmi.rotation.x = -PI/4
	glasscabinet.add_child(svp)
	glasscabinet.add_child(ml2dmi)

var orbitsphere_list :Array
func orbit_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	glasscabinet.set_box_color(Color(Color.WHITE,0.2))
	for i in 9:
		add_orbitsphere(glasscabinet, i)
func add_orbitsphere(glasscabinet :GlassCabinet, i :int) -> void:
	var diagonal_length := WorldSize.length()/19 *i +10
	var a120 := PI*2/3
	var a30 := PI/6
	var axis1 := Vector3.UP.rotated(
		[Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK].pick_random(),
		a30)
	var mat1 := StandardMaterial3D.new()
	mat1.albedo_color = random_color()
	var mat2 := StandardMaterial3D.new()
	mat2.albedo_color = random_color()
	var os = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate(
		).궤도설정(diagonal_length, diagonal_length/200, axis1, a120*[0,1,2].pick_random()
		).구설정(WorldSize.x/400*i+1, WorldSize.x/50, Vector3.UP
		).구재질설정(mat2).궤도재질설정(mat1)
	glasscabinet.add_child(os)
	orbitsphere_list.append(os)

var calendar :Calendar3D
func calendar_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	calendar = preload("res://calendar_3d/calendar_3d.tscn").instantiate(
		).init(WorldSize.x/2, WorldSize.y, WorldSize.z/10, WorldSize.y/2.0/6 , false )
	calendar.rotate_y(PI/2)
	calendar.rotate_x(PI/2)
	glasscabinet.add_child(calendar)

var clock :AnalogClock3D
func clock_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	clock = preload("res://analog_clock_3d/analog_clock_3d.tscn").instantiate(
		).init(WorldSize.x/4, WorldSize.z/10, WorldSize.y/2.0/7 ,9.0, false )
	clock.rotate_y(PI/2)
	clock.rotate_x(PI/2)
	glasscabinet.add_child(clock)

var bartree_scene = preload("res://bar_tree/bar_tree.tscn")
var bartree_list :Array
func bartree_demo(glasscabinet :GlassCabinet, labeltext :String = "") -> void:
	if labeltext != "":
		glasscabinet.set_label_text(labeltext)
		demo_name_to_glass_cabinet[labeltext] = glasscabinet
	var tree_size := Vector3(WorldSize.z/3, WorldSize.y, WorldSize.z / 30)
	make_tree3(randi_range(1,7), glasscabinet, tree_size, randi_range(20,100), Vector3(-WorldSize.x/4,-WorldSize.y/2,0))
	make_tree3(randi_range(1,7), glasscabinet, tree_size, randi_range(20,100), Vector3(WorldSize.x/4,-WorldSize.y/2,0))
func make_tree3(make_flag:int, glasscabinet :GlassCabinet, tree_size :Vector3, bar_count :int, pos :Vector3) -> void:
	if make_flag & (1<<0) != 0: # add left side
		make_sub_tree(glasscabinet, tree_size, bar_count, 2.0, pos)
	if make_flag & (1<<1) != 0: # add right side
		make_sub_tree(glasscabinet, tree_size, bar_count, -2.0, pos)
	if make_flag & (1<<2) != 0: # add center
		if make_flag == (1<<2): # side not exist
			tree_size.x *= 3
		else:
			tree_size.x *= 0.9
		make_sub_tree(glasscabinet, tree_size, bar_count, 0, pos)
func make_sub_tree(glasscabinet :GlassCabinet, tree_size :Vector3, bar_count :int, shift :float, pos :Vector3) -> void:
	var t = bartree_scene.instantiate()
	glasscabinet.add_child(t)
	t.position = pos
	t.init_bartree_with_color(random_color(), random_color(), bar_count)
	t.init_bartree_transform(tree_size, shift)
	bartree_list.append(t)


func _process(delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	label_demo()
	if wavegauge_box !=null:
		wavegauge_box.animate_wave(now)
	if wavegauge_plane !=null:
		wavegauge_plane.animate_wave(now)
	if roulette !=null:
		roulette.장식돌리기()
		roulette.선택된cell강조상태켜기()
	for bt in bartree_list:
		bt.rotate_tree_bar_y(delta*10)
	for os in orbitsphere_list:
		os.animate_rotate(now, delta)
	for mt in meshtrail_list:
		mt.move_trail(delta, bounce_fn, trailmesh_radius, 4*PI,)
	tornado_animate()
	animate_turbine_tree(delta)
	$GlassCabinetContainer1.rotate_y(delta/10)
	$GlassCabinetContainer2.rotate_y(-delta/10)

	main_animation.handle_animation()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

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
		elif $CenterCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($CenterCameraLight, fi)
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()
