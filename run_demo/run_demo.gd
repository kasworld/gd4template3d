extends Node3D

var glass_cabinet_list :Array
var empty_cursor :int
var demo_name_to_glass_cabinet := {}
func make_glass_cabinet(cabinet_size :Vector3) -> void:
	var count := 24
	var unit_rad := 2*PI/ count
	for i in count:
		var radius := cabinet_size.length() *1.7
		var gc :GlassCabinet = preload("res://glass_cabinet/glass_cabinet.tscn").instantiate(
			).init(cabinet_size)
		var rad := i * unit_rad
		if i % 2 == 0:
			gc.position = Vector3(sin(rad)*radius, gc.cabinet_size.y/2 *1.0, cos(rad)*radius)
			$GlassCabinetContainer1.add_child(gc)
		else:
			gc.position = Vector3(sin(rad)*radius, -gc.cabinet_size.y/2 *1.0, cos(rad)*radius)
			$GlassCabinetContainer2.add_child(gc)
		gc.look_at( Vector3(0,gc.position.y,0), Vector3.UP, true)
		gc.set_title_text("%d" % i).show_title(true)
		glass_cabinet_list.append(gc)

func run_demo(demo :Callable, text :String) -> void:
	var gc :GlassCabinet = glass_cabinet_list[empty_cursor]
	empty_cursor += 1
	demo.call(gc)
	gc.set_title_text(text)
	demo_name_to_glass_cabinet[text] = gc
	add_camera_dict.call(gc.get_camera_light(), text)

var add_camera_dict :Callable
func setup_demo_to_cabinet(add_camera_dict_a :Callable) -> void:
	add_camera_dict = add_camera_dict_a
	run_demo(bartree_demo, "bartree")
	run_demo(clock_calendar_demo, "clock calender")
	run_demo(orbit_demo, "orbit")
	run_demo(line2d_demo, "moveline2d")
	run_demo(meshtrail_demo, "meshtrail")
	run_demo(maze3d_demo, "maze3d")
	run_demo(slotreel_demo, "slotreel")
	run_demo(wheel_demo, "roulettewheel" )
	run_demo(props_demo, "props")
	run_demo(wirenet_wavegauge_demo, "wirenet,wavegauge")
	run_demo(wavegauge_demo, "wavegauge")
	run_demo(tornado_demo, "tornado")
	run_demo(platonic_solids_demo, "platonic solids")
	run_demo(winter_tree_demo, "winter tree")
	run_demo(dialgauge_demo, "dial gauge")
	print_debug("remain glass cabinet %d\ndemo count %s" % [
		glass_cabinet_list.size()-empty_cursor,demo_name_to_glass_cabinet.size()])


func _process(delta: float) -> void:
	var gc :GlassCabinet = glass_cabinet_list.slice(empty_cursor).pick_random()
	var lights := randi_range(0,256)
	gc.lights.set_light_on_all(lights)
	gc.lights.set_light_color(NamedColors.random_color(), lights)

	var now := Time.get_unix_time_from_system()
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
	meshtrail_animate(delta)
	tornado_animate()
	wintertree_animate(delta)
	dialgauge_animate()
	clock_calendar_animation.handle_animation()
	$GlassCabinetContainer1.rotate_y(delta/10)
	$GlassCabinetContainer2.rotate_y(-delta/10)
	platonic_solids_animation.handle_animation()
	props_animation.handle_animation()


func make_rand_range(v :float, l :float) -> Array:
	var r1 := randf_range(v,v+l)
	var r2 := randf_range(r1+l/2,r1+l)
	return [r1,r2]
func new_dialgauge(radius :float, cabinet_size :Vector3) -> DialGauge:
	return preload("res://dial_gauge/dial_gauge.tscn").instantiate(
		).init(radius, cabinet_size.z/20, NamedColors.random_color(),NamedColors.random_color(),NamedColors.random_color(),
		).init_range( make_rand_range(0,360), make_rand_range(0,2*PI)
		).add_dial_num(radius*0.80, cabinet_size.z/100, radius/20, 12, NamedColors.random_color(),
		).add_dial_bar(radius*0.92, Vector3(cabinet_size.z/40, cabinet_size.z/200, cabinet_size.z/100),
			DialGauge.BarAlign.Out, 60, NamedColors.random_color()
		).add_dial_bar(radius*0.92, Vector3(cabinet_size.z/40, cabinet_size.z/200, cabinet_size.z/100),
			DialGauge.BarAlign.In, 12, NamedColors.random_color()
		)
var dialgauge_list :Array
func dialgauge_demo(gc :GlassCabinet) -> void:
	#gc.show_wall_box(false)
	var radius := gc.cabinet_size.x/5
	var dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = gc.calc_pos_by_grid(0,0,2,1)
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = gc.calc_pos_by_grid(1,0,2,1)
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	radius = gc.cabinet_size.x/10
	dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = gc.calc_pos_by_grid(1,0,3,3)
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = gc.calc_pos_by_grid(1,2,3,3)
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
func dialgauge_animate() -> void:
	for dg in dialgauge_list:
		dg[1] += randfn(0,1)*dg[0].value_range_len()/100
		dg[1] = dg[0].clamp_value(dg[1])
		dg[0].set_needle_value(dg[1])


func winter_tree_demo(gc :GlassCabinet) -> void:
	var bmesh := PrismMesh.new()
	bmesh.size = Vector3(1,0.3,1)
	winter_tree = preload("res://winter_tree/winter_tree.tscn").instantiate(
		).init(gc.cabinet_size.y, gc.cabinet_size.z/2, gc.cabinet_size.y*2, PI, 1.0,
		).set_center_color(Color.GREEN)
	gc.add_child(winter_tree)
	#$"왼쪽패널/LabelTree".text = "branch count %d" % [ winter_tree.가지들얻기().multimesh.instance_count ]
	winter_tree.position.y = -gc.cabinet_size.y/2
	winter_tree_inst_index = winter_tree.make_index_array()

var winter_tree :WinterTree
enum AniDir { Up, Down, Left , Right }
var winter_tree_inst_index :Array
var color_fn_args := ListIter.new( [[0],[1],[2],[0,1],[1,2],[2,0], [0,1,2]] )
var color_fn :Callable = RandomColor.pure_color
var ani_dir_data := ListIter.new( [AniDir.Up, AniDir.Down, AniDir.Left , AniDir.Right] )
var change_count := 0
func wintertree_animate(delta :float) -> void:
	winter_tree.rotate_y(delta)
	var lines :MultiMeshShape = winter_tree.가지들얻기()
	var co :Color = color_fn.call(color_fn_args.get_current())
	var ani_ended :bool = false
	match ani_dir_data.get_current():
		AniDir.Up:
			for i in winter_tree_inst_index[-change_count-1]:
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index.size()
		AniDir.Down:
			for i in winter_tree_inst_index[change_count]:
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index.size()
		AniDir.Left:
			for a :Array in winter_tree_inst_index:
				if change_count >= a.size():
					continue
				var i = a[change_count]
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index[-1].size()
		AniDir.Right:
			for a :Array in winter_tree_inst_index:
				if change_count >= a.size():
					continue
				var i = a[-change_count-1]
				lines.set_inst_color(i, co)
			change_count +=1
			ani_ended = change_count >= winter_tree_inst_index[-1].size()
	winter_tree.장식들얻기().set_inst_color( randi_range(0, winter_tree.장식들얻기().multimesh.instance_count-1),  NamedColors.random_color())

	if ani_ended:
		color_fn_args.get_next()
		ani_dir_data.get_next()
		change_count = 0
		color_fn = [RandomColor.pure_color, RandomColor.rate_color, random_color2].pick_random()
		winter_tree.장식들얻기().set_color_all( NamedColors.random_color())

var named_color_list := ListIter.new(NamedColors.color_list)
func random_color2(_arg ) -> Color:
	return named_color_list.get_next()


var platonic_solid_list :Array = []
func platonic_solids_demo(gc :GlassCabinet) -> void:
	#gc.show_wall_box(false)
	for ll in [
		[4, 0.5,  [2, 0], 0, 3 ],
		[4, 1.0,  [2, 1], 0, 3 ],
		[4, 2.0,  [2, 2], 0, 3 ],
		[6, 2.0,  [0, 0], 0, 3 ],
		[6, 1.0,  [1, 0], 3, 7 ],
		[8, 2.0,  [0, 1], 0, 4 ],
		[8, 1.0,  [1, 1], 0, 5 ],
		[20, 2.0, [0, 2], 0, 5 ],
		[20, 1.0, [1, 2], 5, 10 ],
		[12, 2.0, [3, 0], 0, 3 ],
		[12, 1.0, [3, 1], 3, 9 ],
		[12, 1.0, [3, 2], 9, 18 ],
	]:
		var face :int = ll[0]
		var from :int = ll[3]
		var to :int = ll[4]
		var wire_width :float = ll[1]
		var ws :WireSolid = preload("res://wire_solid/wire_solid.tscn").instantiate(
			).init(face, from, to, gc.cabinet_size.length()/13 , wire_width, NamedColors.random_color())
		gc.add_child(ws)
		platonic_solid_list.append(ws)
		ws.position = gc.calc_pos_by_grid(ll[2][0],ll[2][1], 4,3)
	platonic_solids_animation.animation_ended.connect(platonic_solids_animation_ended)
	start_platonic_solids_animation()

var platonic_solids_animation := SimpleAnimation.new()
func platonic_solids_animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	if platonic_solids_animation.is_empty():
		start_platonic_solids_animation()
func start_platonic_solids_animation() -> void:
	for ps in platonic_solid_list:
		var diff :float = [PI/2,-PI/2].pick_random()
		var axis :int = [Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random()
		platonic_solids_animation.start_rotate_subfield(
			"ani_rot", ps, axis , ps.rotation[axis], ps.rotation[axis] + diff, 1.0)


var tornado_list :Array # [ tornado , AnimateGradient , AnimateGradient ]
func tornado_demo(gc :GlassCabinet) -> void:
	#gc.show_wall_box(false)
	for i in 4:
		var tb = preload("res://tornado/tornado.tscn").instantiate(
			).init_sample(gc.cabinet_size.x/2, gc.cabinet_size.y*0.3, 0.5, NamedColors.random_color(),NamedColors.random_color())
		gc.add_child(tb)
		tornado_list.append([tb, AnimateGradient.new(), AnimateGradient.new()])

func scale_tornado(rate):
	return Vector3(rate,1,rate)*rate
func shift_tornado_lambda(t :float, shift :float) -> Callable:
	return func(rate):
		var period := 5
		return Vector3(cos(rate*period), 0, sin(rate*period)) * t * shift

func tornado_animate() -> void:
	var t := Time.get_unix_time_from_system()
	var rad := fposmod(t, PI*2)
	var unit_rad := 2*PI/4
	var gc :GlassCabinet = tornado_list[0][0].get_parent()
	var radius := gc.cabinet_size.z/2
	for i in tornado_list.size():
		var tt := t+ i
		tornado_list[i][0].set_transform_all(scale_tornado, shift_tornado_lambda( sin(tt), gc.cabinet_size.x/10) )
		tornado_list[i][0].set_color_all(tornado_list[i][1].get_color(),tornado_list[i][2].get_color())
		tornado_list[i][1].inc_rate()
		tornado_list[i][2].inc_rate()
		tornado_list[i][0].position = Vector3(cos(i*unit_rad+t)*radius, sin(i*unit_rad+t*1.7)*radius/2 -gc.cabinet_size.y/4, sin(i*unit_rad+t)*radius)
		tornado_list[i][0].rotation.y = -rad*5

var colorlist_dark :Array = NamedColors.filter_dark_color_list()
var colorlist_light :Array = NamedColors.filter_light_color_list()
var cardlist :Array = PlayingCard.make_deck_with_joker()
func make_color_text_info_list(colist :Array, cdlist :Array) -> Array:
	var rtn := []
	for i in cdlist.size():
		rtn.append( [ colist[i%colist.size()], cdlist[i] ] )
	return rtn

var roulette :Roulette
func wheel_demo(gc :GlassCabinet) -> void:
	gc.show_description()
	var color_text_into_list := make_color_text_info_list(
		colorlist_light, cardlist,
	).duplicate()
	color_text_into_list.shuffle()
	roulette = preload("res://roulette/roulette.tscn").instantiate(
		).init(0, gc.cabinet_size.y/2, gc.cabinet_size.z/20, color_text_into_list )
	roulette.색설정하기(NamedColors.random_color(), NamedColors.random_color(), NamedColors.random_color() )
	roulette.rotation_stopped.connect(wheel결과가결정됨)
	gc.add_child(roulette)
	wheel돌리기()
func wheel돌리기() -> void:
	var rot = randfn(2*PI, PI/2)
	if randi_range(0,1) == 0:
		rot = -rot
	roulette.돌리기시작.call_deferred(rot)
func wheel결과가결정됨(rl :Roulette) -> void:
	rl.get_parent().set_description_text(rl.선택된cell얻기().글내용얻기())
	$TimerWheel.start()
func _on_timer_wheel_timeout() -> void:
	wheel돌리기()

var slot :Slots
func slotreel_demo(gc :GlassCabinet) -> void:
	gc.show_description()
	var symbol크기 := Vector2(gc.cabinet_size.x/20 ,gc.cabinet_size.y/20)
	var color_text_into_list := make_color_text_info_list(colorlist_dark, cardlist).duplicate()
	slot = preload("res://slots/slots.tscn").instantiate().init(5, symbol크기,color_text_into_list)
	gc.add_child(slot)
	slot.rotation_stopped.connect(슬롯멈춤)
	slot.돌리기시작()
func 슬롯멈춤(sl :Slots) -> void:
	var symbol들 := sl.선택된symbol들얻기()
	var 결과 := ""
	for k in symbol들:
		결과 += k.글내용얻기() + " "
	sl.get_parent().set_description_text(결과)
	$TimerReel.start()
func _on_timer_reel_timeout() -> void:
	slot.돌리기시작()


var wavegauge_box :WaveGauge
func wavegauge_demo(gc :GlassCabinet) -> void:
	wavegauge_box = preload("res://wave_gauge/wave_gauge.tscn").instantiate(
		).init(Vector3(gc.cabinet_size.x-1,gc.cabinet_size.y-1,gc.cabinet_size.z-1), Vector3i(32,32,32), WaveGauge.color_list, 0.1, 1.0 )
	gc.add_child(wavegauge_box)

var wirenet :MultiMeshShape
var wavegauge_plane :WaveGauge
func wirenet_wavegauge_demo(gc :GlassCabinet) -> void:
	var grid_size := Vector2i(16,9)*2
	wirenet = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate(
		).init_wire_net(Vector2(gc.cabinet_size.x,gc.cabinet_size.y), Vector2i(grid_size.x,grid_size.y), gc.cabinet_size.x/grid_size.x/10, NamedColors.random_color())
	gc.add_child(wirenet)
	wavegauge_plane = preload("res://wave_gauge/wave_gauge.tscn").instantiate(
		).init(Vector3(gc.cabinet_size.x,gc.cabinet_size.y,gc.cabinet_size.z/20), Vector3i(grid_size.x,grid_size.y,1), WaveGauge.color_list, 0.1, 1.0 )
	gc.add_child(wavegauge_plane)

var maze3d :Maze3D
func maze3d_demo(gc :GlassCabinet) -> void:
	var ms := Maze3DSetting.new_default()
	ms.MazeSize = Vector2i(16,9)
	ms.LaneW = gc.cabinet_size.x/ms.MazeSize.x-0.1
	ms.StoryH = ms.LaneW
	ms.WallThick = ms.LaneW *0.1
	ms.MakeSubWallRate = 0.1
	maze3d = preload("res://maze_3d/maze_3d.tscn").instantiate(
		).init_with_color( ms, Callable(), NamedColors.random_color(), NamedColors.random_color(), NamedColors.random_color() )
	maze3d.rotation.x = PI/4
	maze3d.view_floor_ceiling(false,false)
	gc.add_child(maze3d)

var trailmesh_radius :float
func meshtrail_animate(delta :float) -> void:
	for mt in meshtrail_list:
		mt.move_trail(delta, bounce_fn, trailmesh_radius, 4*PI,)
var meshtrail_list :Array
var bound_aabb :AABB
func meshtrail_demo(gc :GlassCabinet) -> void:
	trailmesh_radius = gc.cabinet_size.length()/100
	bound_aabb = AABB( -gc.cabinet_size/2, gc.cabinet_size)
	var mesh := BoxMesh.new()
	mesh.material = MultiMeshShape.make_color_material()
	mesh.size = Vector3(trailmesh_radius*3, trailmesh_radius /5, trailmesh_radius/5)
	for i in 10:
		make_meshtrail(gc, i %4, mesh, 100, bound_aabb.get_center())
func make_meshtrail(gc :GlassCabinet, mt_type:int, mesh :Mesh, count :int, pos :Vector3 ) -> void:
	var mt = preload("res://mesh_trail/mesh_trail.tscn").instantiate(
		).init_with_color_mesh(mesh, count, true, pos,
		).set_speed(trailmesh_radius*20,trailmesh_radius*40)
	gc.add_child(mt)
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

var prop_list :Array
func props_demo(gc :GlassCabinet) -> void:
	gc.show_axis_arrow()
	var prop = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(NamedColors.random_color()).set_size( gc.cabinet_size.x/5, gc.cabinet_size.x/100, gc.cabinet_size.x/25,0.3)
	prop.position = gc.calc_pos_by_grid(0,0,2,2)
	gc.add_child(prop)
	prop_list.append(prop)
	prop = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(NamedColors.random_color()).set_size( gc.cabinet_size.x/5, gc.cabinet_size.x/70, gc.cabinet_size.x/25)
	prop.position = gc.calc_pos_by_grid(1,0,2,2)
	gc.add_child(prop)
	prop_list.append(prop)
	prop = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(gc.cabinet_size.x/20, gc.cabinet_size.x/10, 8, NamedColors.random_color())
	prop.position = gc.calc_pos_by_grid(0,1,2,2)
	gc.add_child(prop)
	prop_list.append(prop)
	prop = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(gc.cabinet_size.x/10, gc.cabinet_size.x/20, 4, NamedColors.random_color())
	prop.position = gc.calc_pos_by_grid(1,1,2,2)
	gc.add_child(prop)
	prop_list.append(prop)

	props_animation.animation_ended.connect(props_animation_ended)
	start_props_animation()

var props_animation := SimpleAnimation.new()
func props_animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	if props_animation.is_empty():
		start_props_animation()
func start_props_animation() -> void:
	for ps in prop_list:
		var diff :float = [PI/2,-PI/2].pick_random()
		var axis :int = [Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random()
		props_animation.start_rotate_subfield(
			"ani_rot", ps, axis , ps.rotation[axis], ps.rotation[axis] + diff, 1.0)

func line2d_demo(gc :GlassCabinet) -> void:
	#gc.show_wall_box(false)
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
	ml2dmi.mesh.size = Vector2(gc.cabinet_size.x, gc.cabinet_size.y)
	ml2dmi.mesh.orientation = PlaneMesh.FACE_Z
	ml2dmi.material_override = StandardMaterial3D.new()
	ml2dmi.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	ml2dmi.material_override.albedo_texture = svp.get_texture()
	#ml2dmi.rotation.x = -PI/4
	gc.add_child(svp)
	gc.add_child(ml2dmi)

var orbitsphere_list :Array
func orbit_demo(gc :GlassCabinet) -> void:
	#gc.show_wall_box(false)
	for i in 9:
		add_orbitsphere(gc, i, 9)
func add_orbitsphere(gc :GlassCabinet, i :int, count :int) -> void:
	var rate := float(i)/float(count-1) * 0.5 + 0.5
	var diagonal_length := gc.cabinet_size.length()/2 * rate
	var a120 := PI*2/3
	var a30 := PI/6
	var axis1 := Vector3.UP.rotated(
		[Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK].pick_random(),
		a30)
	var 궤도mat1 := StandardMaterial3D.new()
	궤도mat1.albedo_color = NamedColors.random_color()
	var 구mat2
	match i:
		0,1,2,3:
			구mat2 = [
				preload("res://earthmoon/sun_mat.tres"),
				preload("res://earthmoon/earth_mat.tres"),
				preload("res://earthmoon/moon_mat.tres"),
				preload("res://image/leaf.tres"),
				][i]
		_:
			구mat2 = StandardMaterial3D.new()
			구mat2.albedo_color = NamedColors.random_color()
	var os = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate(
		).궤도설정(diagonal_length, diagonal_length/200, axis1, a120*[0,1,2].pick_random()
		).구설정(gc.cabinet_size.x/400*i+1, gc.cabinet_size.x/50, Vector3.UP
		).구재질설정(구mat2).궤도재질설정(궤도mat1)
	gc.add_child(os)
	orbitsphere_list.append(os)

var clock_calendar_animation := SimpleAnimation.new()
func clock_calendar_animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	if clock_calendar_animation.is_empty():
		start_clock_calendar_animation()
var clock_calendar_pos_list := []
var clock_calendar_rot_args := [ [0.0, 2*PI], [2*PI, 0.0] ]
func reset_clock_calendar_pos()->void:
	clock.position = clock_calendar_pos_list[0]
	calendar.position = clock_calendar_pos_list[1]
func start_clock_calendar_animation():
	const ani_speed :float = 3
	clock_calendar_animation.start_move("clock",clock, clock_calendar_pos_list[0], clock_calendar_pos_list[1], ani_speed)
	clock_calendar_animation.start_rotate_subfield("clock",clock, Vector3.Axis.AXIS_Y, clock_calendar_rot_args[0][0] , clock_calendar_rot_args[0][1], ani_speed)
	clock_calendar_animation.start_move("clock",calendar, clock_calendar_pos_list[1], clock_calendar_pos_list[0], ani_speed)
	clock_calendar_animation.start_rotate_subfield("clock",calendar, Vector3.Axis.AXIS_Y, clock_calendar_rot_args[1][0], clock_calendar_rot_args[1][1], ani_speed)
	clock_calendar_pos_list = [clock_calendar_pos_list[1], clock_calendar_pos_list[0]]
	clock_calendar_rot_args = [clock_calendar_rot_args[1], clock_calendar_rot_args[0]]

var calendar :Calendar3D
var clock :AnalogClock3D
func clock_calendar_demo(gc :GlassCabinet) -> void:
	#gc.show_wall_box(false)
	calendar = preload("res://calendar_3d/calendar_3d.tscn").instantiate(
		).init(gc.cabinet_size.x/2, gc.cabinet_size.y, gc.cabinet_size.z/10, gc.cabinet_size.y/2.0/6 , true )
	gc.add_child(calendar)
	clock = preload("res://analog_clock_3d/analog_clock_3d.tscn").instantiate(
		).init(gc.cabinet_size.x/4, gc.cabinet_size.z/10, gc.cabinet_size.y/2.0/7 ,9.0, true )
	gc.add_child(clock)
	clock_calendar_pos_list = [Vector3(-gc.cabinet_size.x/4,0,0), Vector3(gc.cabinet_size.x/4,0,0)]
	reset_clock_calendar_pos()
	clock_calendar_animation.animation_ended.connect(clock_calendar_animation_ended)
	start_clock_calendar_animation()

var bartree_scene = preload("res://bar_tree/bar_tree.tscn")
var bartree_list :Array
func bartree_demo(gc :GlassCabinet) -> void:
	var tree_size := Vector3(gc.cabinet_size.z/3, gc.cabinet_size.y, gc.cabinet_size.z / 30)
	make_tree3(randi_range(1,7), gc, tree_size, randi_range(20,100), Vector3(-gc.cabinet_size.x/4,-gc.cabinet_size.y/2,0), false)
	make_tree3(randi_range(1,7), gc, tree_size, randi_range(20,100), Vector3(gc.cabinet_size.x/4,-gc.cabinet_size.y/2,0), true)
func make_tree3(make_flag:int, gc :GlassCabinet, tree_size :Vector3, bar_count :int, pos :Vector3, use_mat :bool) -> void:
	if make_flag & (1<<0) != 0: # add left side
		make_sub_tree(gc, tree_size, bar_count, 2.0, pos, use_mat)
	if make_flag & (1<<1) != 0: # add right side
		make_sub_tree(gc, tree_size, bar_count, -2.0, pos, use_mat)
	if make_flag & (1<<2) != 0: # add center
		if make_flag == (1<<2): # side not exist
			tree_size.x *= 3
		else:
			tree_size.x *= 0.9
		make_sub_tree(gc, tree_size, bar_count, 0, pos, use_mat)
func make_sub_tree(gc :GlassCabinet, tree_size :Vector3, bar_count :int, shift :float, pos :Vector3, use_mat :bool) -> void:
	var t = bartree_scene.instantiate()
	gc.add_child(t)
	t.position = pos
	if use_mat:
		t.init_bartree_with_material([
				preload("res://earthmoon/sun_mat.tres"),
				preload("res://earthmoon/earth_mat.tres"),
				preload("res://earthmoon/moon_mat.tres"),
				preload("res://image/leaf.tres"),
			].pick_random(), bar_count)
	else:
		t.init_bartree_with_color(NamedColors.random_color(), NamedColors.random_color(), bar_count)
	t.init_bartree_transform(tree_size, shift)
	bartree_list.append(t)
