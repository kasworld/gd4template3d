extends Node3D
class_name RunDemo

static var RandomColorIter := ListIter.new(NamedColors.color_list)

static func MakeSubViewport(n2d :Node2D, size_pixel:Vector2i) -> SubViewport:
	var sv := SubViewport.new()
	sv.size = size_pixel
	#sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	#sv.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	sv.transparent_bg = true
	sv.add_child(n2d)
	return sv

static func MakePlaneSubViewport(svp :SubViewport, mesh_size :Vector2) -> MeshInstance3D:
	var sp := MeshInstance3D.new()
	sp.mesh = PlaneMesh.new()
	sp.mesh.size = mesh_size
	sp.mesh.orientation = PlaneMesh.FACE_Z
	sp.material_override = StandardMaterial3D.new()
	sp.material_override.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	sp.material_override.albedo_texture = svp.get_texture()
	return sp

static func AddRotateRandomAnimation(animation :SimpleAnimation, node3d :Node3D, rotate_range :float = PI) -> void:
	var diff :float =  randf_range(-rotate_range, rotate_range)
	var ani_dur := absf(diff)
	var axis :int = [Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random()
	animation.start_rotation_subfield(
		"ani_rot", node3d, axis , node3d.rotation[axis], node3d.rotation[axis] + diff, ani_dur)

static func AddRotateRandomAnimationAxis(animation :SimpleAnimation, node3d :Node3D, axis :int, rotate_range :float = PI) -> void:
	var diff :float =  randf_range(-rotate_range, rotate_range)
	var ani_dur := absf(diff)
	var ani := SimpleAnimation.MakeAnimationSubfield(
		"ani_rot", node3d, "rotation", axis,
		node3d.rotation[axis], node3d.rotation[axis] + diff, ani_dur)
	animation.add_animation(ani)


static func WaveColorPlot3D(tg :Plot3D, now :float, zrange :float) -> void:
	var cg := tg.calc_grid
	const PI2 = 2*PI
	const sqrt2 := sqrt(2)
	cg.iter_ixyz(func(index:int,xi:int,yi:int,_zi:int):
		var xrate :float= cg.rate_xi(xi)
		var yrate :float= cg.rate_yi(yi)
		# make -1.0 ~ 1.0
		var zrate :=  ( sin( xrate*PI2 +now ) + cos( yrate*PI2 +now) ) / sqrt2
		var t :Transform3D = tg.multimesh.get_instance_transform(index)
		t.origin.z = zrate * zrange
		tg.multimesh.set_instance_transform(index, t)
		var co := Color(xrate,yrate, absf(zrate) )
		tg.multimesh.set_instance_color(index,co)
		)


class AnimateList:
	var animation :SimpleAnimation
	func _init() -> void:
		animation = SimpleAnimation.new()
	var node3d_list :Array
	func set_list(nlist :Array) -> AnimateList:
		node3d_list = nlist
		return self

	func init_rotate(olist :Array, rotate_range :float = PI) -> Callable:
		set_list(olist)
		animation.animation_ended.connect(func(node :Node3D, _ani :Dictionary) -> void:
			RunDemo.AddRotateRandomAnimation(animation, node, rotate_range))
		for node in node3d_list:
			RunDemo.AddRotateRandomAnimation(animation, node, rotate_range)
		return func(_delta:float):
			animation.handle_animation()

	func init_rotate_axis(olist :Array, axis :int, rotate_range :float = PI) -> Callable:
		set_list(olist)
		animation.animation_ended.connect(func(node :Node3D, _ani :Dictionary) -> void:
			RunDemo.AddRotateRandomAnimationAxis(animation, node, axis, rotate_range))
		for node in node3d_list:
			RunDemo.AddRotateRandomAnimationAxis(animation, node, axis, rotate_range)
		return func(_delta:float):
			animation.handle_animation()


var glass_cabinet_iter :ListIter
var used_glass_cabinet_iter :ListIter
var empty_glass_cabinet_iter :ListIter


var mazedemo := MazeDemo.new()

func init(cabinet_list :Array, add_camera_dict :Callable, run1 :Array =[]) -> void:
	glass_cabinet_iter = ListIter.new(cabinet_list, true)
	var run_demo := func(demo :Callable, text :String) -> void:
		var gc :GlassCabinet = glass_cabinet_iter.get_and_next()
		var ani_fn :Callable = demo.call(gc)
		if not ani_fn.is_null():
			gc.add_animate_func(ani_fn)
		gc.set_title_text(text)
		add_camera_dict.call(gc.get_camera_light(), text)

	var run_all := [
		[bartree_demo, "BarTree"],
		[battle_shooter_demo, "Battle Shooter"],
		[clock_calendar_demo, "Clock Calender"],
		[dialgauge_demo, "Dial Gauge"],
		[flower_demo, "꽃"],
		[ladder_demo, "사다리게임"],
		[line2d_demo, "MoveLine2d"],
		[manhwa_face_demo, "만화 얼굴"],
		[mazedemo.maze3d_demo, "Maze3D"],
		[meshtrail_demo, "MeshTrail"],
		[orbit_demo, "Orbit"],
		[platonic_solids_demo, "Platonic Solids"],
		[plot3d_demo, "Plot3d"],
		[plot3d_grid_demo, "Plot3d Grid"],
		[plot3d_image_demo, "Plot3d Image"],
		[props_demo, "Props"],
		[same_game_demo, "Same Game"],
		[seven_segment_demo, "Seven Segment 3D"],
		[slotreel_demo, "SlotReel"],
		[snakebyte_demo, "Snakebyte Game"],
		[tetromino_demo, "Tetromino"],
		[tornado_demo, "Tornado"],
		[wavegauge_box_demo, "WaveGaugeBox"],
		[wheel_demo, "RouletteWheel" ],
		[winter_tree_demo, "Winter Tree"],
		[yutgame_demo, "윷놀이"],
	]
	if not run1.is_empty():
		run_all = [ run1 ]
	for run in run_all:
		run_demo.call(run[0], run[1])

	used_glass_cabinet_iter = ListIter.new(glass_cabinet_iter.get_itered_slice())
	if run_all.size() < glass_cabinet_iter.get_size():
		empty_glass_cabinet_iter = ListIter.new(glass_cabinet_iter.get_unitered_slice())
		for gc in empty_glass_cabinet_iter.get_data_array():
			gc.add_light_animation_to_animate_func_list()
			gc.show_wall_box(true)
	else :
		empty_glass_cabinet_iter = ListIter.new([])
	print_debug("remain glass cabinet %d\ndemo count %s" % [
		empty_glass_cabinet_iter.get_size(),used_glass_cabinet_iter.get_size() ])

func plot3d_demo(gc :GlassCabinet) -> Callable:
	var plot3d :Plot3D = preload("res://plot_3d/plot_3d.tscn").instantiate()
	plot3d.init_plot3d_box(gc.aabb.size, gc.aabb.size, 0.9, false)
	gc.add_child(plot3d)

	plot3d.draw_texture2d_face_y(Vector3i(0,0,0), preload("res://image/blender.png"))
	plot3d.draw_texture2d_face_x(Vector3i(0,0,0), preload("res://image/gimp.png"))
	plot3d.draw_texture2d_face_z(Vector3i(0,0,0), preload("res://image/me.png"))
	var cg := plot3d.calc_grid
	plot3d.draw_x_line(0, cg.grid_size.x, cg.grid_size.y/2, cg.grid_size.z/2, Color.RED)
	plot3d.draw_y_line(cg.grid_size.x/2, 0, cg.grid_size.y, cg.grid_size.z/2, Color.GREEN)
	plot3d.draw_z_line(cg.grid_size.x/2, cg.grid_size.y/2,0, cg.grid_size.z, Color.BLUE)
	return Callable()

func flower_demo(gc :GlassCabinet) -> Callable:
	var grid_gc := gc.make_CalcGrid3D( Vector3i(16,9,1))
	var node3d_list :Array = []
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	for i in grid_gc.get_grid_count():
		var fl :Flower = preload("res://flower/flower.tscn").instantiate()
		var flower_r := grid_gc.unit_size.x/3
		var petal_count :int = [2,3,4,5,6,8,10,12,16,20,24].pick_random()
		var petal_width_scale := randf_range(0.3, 0.8)
		var petal_radial :int = [4,5,6,32].pick_random()
		var interleave_petal := false
		if petal_count > 8 :
			petal_width_scale = randf_range(0.2, 0.5)
			#interleave_petal = true
		fl.init_petal(flower_r, randf_range(flower_r*0.3,flower_r*0.6),
			petal_count, RandomColorIter.get_and_next(), petal_width_scale, petal_radial, interleave_petal)
		if petal_count <= 3:
			petal_count *=2
		fl.init_center(randf_range(flower_r*0.1,flower_r*0.5), RandomColorIter.get_and_next(), petal_count)
		fl.rotation_axis(Vector3.Axis.AXIS_X)
		afterfn.call(i,fl)
	return AnimateList.new().init_rotate_axis(node3d_list, Vector3.Axis.AXIS_Z)

var colors_dark := NamedColors.filter_dark_color_list()
var colors_light := NamedColors.filter_light_color_list()

func manhwa_face_demo(gc :GlassCabinet) -> Callable:
	var grid_gc := gc.make_CalcGrid3D( Vector3i(16,9,1))
	var node3d_list :Array = []
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	for i in grid_gc.get_grid_count():
		var face :ManhwaFace = preload("res://manhwa_face/manhwa_face.tscn").instantiate()
		face.set_radius(grid_gc.unit_size.x/4)
		face.set_ear_type(randi_range(0,2))
		face.set_ear_rad(randf_range(PI/16, PI/3), randfn(0.0,0.1))
		face.set_face_color(RandomColorIter.get_and_next())
		face.set_eye_color(colors_light.pick_random(),colors_dark.pick_random())
		face.set_eye_Sclera_scale(Vector3(randfn(1.0,0.1) , 1, randfn(1.0,0.1)))
		face.set_eye_Iris_scale(Vector3(randfn(1.0,0.1) , 1, randfn(1.0,0.1)))
		face.set_eye_Iris_radius_rate(randfn(0.5,0.2))
		face.rotation_axis(Vector3.Axis.AXIS_X, -PI/2)
		afterfn.call(i, face)

	var animate := func() -> void:
		for i in node3d_list.size():
			var now := randf_range(0, 2*PI)
			var node :ManhwaFace = node3d_list[i]
			match i %4 :
				0:
					node.move_eye_Iris(cos(now), sin(now) )
					node.set_ear_rad(cos(now))
				1:
					node.move_eye_Iris(-cos(now), sin(now))
					node.set_ear_rad(sin(now))
				2:
					node.move_eye_Iris(cos(now), 0 )
					node.set_ear_rad(cos(now))
				3:
					node.move_eye_Iris(0, sin(now))
					node.set_ear_rad(sin(now))
	animate.call()
	return Callable()

func seven_segment_demo(gc :GlassCabinet) -> Callable:
	gc.show_description()
	var grid_gc := gc.make_CalcGrid3D( Vector3i(5,2,1))
	var node3d_list :Array = []
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	for i in grid_gc.get_grid_count():
		var ss :SevenSegment = preload("res://seven_segment/seven_segment.tscn").instantiate()
		var ss_size := grid_gc.unit_size
		ss_size.z = (grid_gc.unit_size.z / 100) * (1+ i*1)
		ss_size *= 0.5
		ss.init(ss_size, ss_size.x /(i+4.0),  RandomColorIter.get_and_next())
		ss.show_segment_by_flag( SevenSegment.NumToFlag[i])
		afterfn.call(i, ss)
	return func(_delta :float) -> void:
		if randf() > 0.1:
			return
		var nth :int = randi_range(0,9)
		var ss :SevenSegment = node3d_list.pick_random()
		ss.show_segment_by_flag(SevenSegment.NumToFlag[nth] )


func tetromino_demo(gc :GlassCabinet) -> Callable:
	gc.show_description()
	var grid_gc := gc.make_CalcGrid3D( Vector3i(32,18,1) )
	var tetromino_list :Array = []
	for t in Tetromino.Type.size():
		var tetromino :Tetromino = preload("res://polyomino/tetromino/tetromino.tscn").instantiate(
			).init(t, 0, grid_gc.unit_size.x)
		gc.add_child(tetromino)
		tetromino.position = grid_gc.get_n_th_lanepos( randi_range(0, grid_gc.get_grid_count()-1) )
		tetromino_list.append(tetromino)
	var tetromino_iter := ListIter.new(tetromino_list)
	return func(_delta :float) -> void:
		for tt in tetromino_list:
			tt.animation.handle_animation()
		var tet :Tetromino = tetromino_iter.get_and_next()
		if tet.animation.is_empty():
			var n := randi_range(0,7)
			match n:
				0,1,2,3,4,5:
					var dir :Vector3 = [Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK][n]
					tet.animate_rotation_to_dir(dir)
					if dir.z == 0:
						var dstpos := tet.position + dir*grid_gc.unit_size
						if grid_gc.has_point(dstpos):
							tet.animate_move_to( dstpos )
				6:
					tet.animate_morph_to(tet.tetromino_type, tet.get_right_rotation())
				7:
					tet.animate_morph_to(tet.tetromino_type, tet.get_left_rotation())


var battleshooter :BattleShooter
func battle_shooter_demo(gc :GlassCabinet) -> Callable:
	#gc.set_light_shadow(true, GlassCabinet.BitFlagAllLight)
	gc.show_description()
	var sz := gc.aabb.size
	battleshooter = preload("res://battle_shooter_3d/battle_shooter.tscn").instantiate(
		).init(sz)
	gc.add_child(battleshooter)
	return Callable()


var yutgame :윷놀이
func yutgame_demo(gc :GlassCabinet) -> Callable:
	yutgame = preload("res://윷놀이/윷놀이.tscn").instantiate().init(gc.aabb.size)
	gc.add_child(yutgame)
	yutgame.game_ended.connect(yutgame_ended)
	yutgame.new_game()
	return Callable()
func yutgame_ended(_game :윷놀이) -> void:
	yutgame.new_game()


var ladder :사다리게임
var 길번호 :int
var 밝은색목록 :ListIter = ListIter.new(NamedColors.filter_light_color_list())
func ladder_demo(gc :GlassCabinet) -> Callable:
	var 참가자정보 :Array
	for i in 8:
		참가자정보.append( ["출발%d" % [i+1], 밝은색목록.get_and_next(), "도착%d" % [i+1] ] )
	ladder = preload("res://사다리게임/사다리게임.tscn").instantiate(
		).init(gc.aabb.size, 참가자정보)
	gc.add_child(ladder)
	ladder.사다리풀이그리기()
	$"Timer길보기".start(3.0)
	return func(delta) -> void:
		ladder.rotate_y(delta/2)
func _on_timer길보기_timeout() -> void:
	ladder.길하나보기(길번호)
	길번호 = (길번호+1) % ladder.참가자정보.size()


var snake_byte_game :SnakeByte
var game_info :Dictionary
func snakebyte_demo(gc :GlassCabinet) -> Callable:
	#gc.get_camera_light().get_light().visible = false
	#gc.lights.set_light_energy(10, BitFlag.MakeFilledFlags( $GlassCabinet.lights.get_size() ))
	snake_byte_game = preload("res://snake_byte/snake_byte.tscn").instantiate(
		).init(gc.aabb.size)
	gc.add_child(snake_byte_game)
	snake_byte_game.game_ended.connect(game_ended)
	snake_byte_game.score_changed.connect(score_changed)
	new_snakebytegame(true)
	return Callable()
func new_snakebytegame(demo_mode :bool) -> void:
	game_info = {
		"score" : 0,
		"snake" : SnakeByte.SnakeLife,
		"stage_number" : 0,
		"demo_mode" : demo_mode,
	}
	snake_byte_game.new_game(game_info)
func score_changed(_score :float) -> void:
	pass
func game_ended(_game :SnakeByte) -> void:
	new_snakebytegame(true)
func end_demo_start_game() -> void:
	new_snakebytegame(false)


var samegame :SameGame
var samegame_level :int
func same_game_demo(gc :GlassCabinet) -> Callable:
	gc.show_description()
	samegame = preload("res://same_game/same_game.tscn").instantiate(
		).init(gc.aabb.size)
	gc.add_child(samegame)
	samegame.game_ended.connect(samegame_ended)
	samegame.score_changed.connect(update_samegame_score_label)
	samegame.new_game(samegame_level)
	return Callable()
func samegame_ended(_game :SameGame) -> void:
	samegame_level += 1
	samegame.new_game(samegame_level)
func update_samegame_score_label(점수 :float) -> void:
	samegame.get_parent().set_description_text("현재점수 %d" % 점수 )


func make_rand_range(v :float, l :float) -> Array:
	var r1 := randf_range(v,v+l)
	var r2 := randf_range(r1+l/2,r1+l)
	return [r1,r2]
func new_dialgauge(radius :float, cabinet_size :Vector3) -> DialGauge:
	return preload("res://dial_gauge/dial_gauge.tscn").instantiate(
		).init(radius, cabinet_size.z/20, RandomColorIter.get_and_next(),RandomColorIter.get_and_next(),RandomColorIter.get_and_next(),
		).init_range( make_rand_range(0,360), make_rand_range(0,2*PI)
		).add_dial_num(radius*0.80, cabinet_size.z/100, radius/20, 12, RandomColorIter.get_and_next(),
		).add_dial_bar(radius*0.92, Vector3(cabinet_size.z/40, cabinet_size.z/200, cabinet_size.z/100),
			DialGauge.BarAlign.Out, 60, RandomColorIter.get_and_next()
		).add_dial_bar(radius*0.92, Vector3(cabinet_size.z/40, cabinet_size.z/200, cabinet_size.z/100),
			DialGauge.BarAlign.In, 12, RandomColorIter.get_and_next()
		)
var dialgauge_list :Array
func dialgauge_demo(gc :GlassCabinet) -> Callable:
	var radius := gc.aabb.size.x/5
	var grid21 := gc.make_CalcGrid3D(Vector3i(2,1,1))
	var grid33 := gc.make_CalcGrid3D(Vector3i(3,3,1))
	var dg = new_dialgauge(radius, gc.aabb.size)
	dg.position = grid21.posi_to_lanepos(Vector3i(0,0,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	dg = new_dialgauge(radius, gc.aabb.size)
	dg.position = grid21.posi_to_lanepos(Vector3i(1,0,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	radius = gc.aabb.size.x/10
	dg = new_dialgauge(radius, gc.aabb.size)
	dg.position = grid33.posi_to_lanepos(Vector3i(1,0,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	dg = new_dialgauge(radius, gc.aabb.size)
	dg.position = grid33.posi_to_lanepos(Vector3i(1,2,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	return func (_delta :float) -> void:
		for dig in dialgauge_list:
			dig[1] += randfn(0,1)*dig[0].value_range_len()/100
			dig[1] = dig[0].clamp_value(dig[1])
			dig[0].set_needle_value(dig[1])


func winter_tree_demo(gc :GlassCabinet) -> Callable:
	var bmesh := PrismMesh.new()
	bmesh.size = Vector3(1,0.3,1)
	winter_tree = preload("res://winter_tree/winter_tree.tscn").instantiate(
		).init(gc.aabb.size.y, gc.aabb.size.z/2, gc.aabb.size.y*2, PI, 1.0,
		).set_center_color(Color.GREEN)
	gc.add_child(winter_tree)
	#$"왼쪽패널/LabelTree".text = "branch count %d" % [ winter_tree.가지들얻기().multimesh.instance_count ]
	winter_tree.position.y = -gc.aabb.size.y/2
	winter_tree_inst_index = winter_tree.make_index_array()
	return wintertree_animate

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
	winter_tree.장식들얻기().set_inst_color( randi_range(0, winter_tree.장식들얻기().multimesh.instance_count-1),  RandomColorIter.get_and_next())

	if ani_ended:
		color_fn_args.next()
		ani_dir_data.next()
		change_count = 0
		color_fn = [RandomColor.pure_color, RandomColor.rate_color, random_color2].pick_random()
		winter_tree.장식들얻기().set_color_all( RandomColorIter.get_and_next())

func random_color2(_arg ) -> Color:
	return RandomColorIter.get_and_next()


func platonic_solids_demo(gc :GlassCabinet) -> Callable:
	var node3d_list :Array = []
	var grid_gc := gc.make_CalcGrid3D(Vector3i(4,3,1))
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	var i:= 0
	for ll in [
		[4, 0.5,  0, 3 ],
		[4, 1.0,  0, 3 ],
		[4, 2.0,  0, 3 ],
		[6, 2.0,  0, 3 ],
		[6, 1.0,  3, 7 ],
		[8, 2.0,  0, 4 ],
		[8, 1.0,  0, 5 ],
		[20, 2.0, 0, 5 ],
		[20, 1.0, 5, 10 ],
		[12, 2.0, 0, 3 ],
		[12, 1.0, 3, 9 ],
		[12, 1.0, 9, 18 ],
	]:
		var face :int = ll[0]
		var wire_width :float = ll[1] * gc.aabb.size.length() /300
		var from :int = ll[2]
		var to :int = ll[3]
		var ws :WireSolid = preload("res://wire_solid/wire_solid.tscn").instantiate(
			).init(face, from, to, grid_gc.unit_size.y/2-wire_width , wire_width, RandomColorIter.get_and_next(), wire_width )
		afterfn.call(i,ws)
		i +=1
	return AnimateList.new().init_rotate(node3d_list)


var tornado_list :Array # [ tornado , AnimateGradient , AnimateGradient ]
func tornado_demo(gc :GlassCabinet) -> Callable:
	for i in 4:
		var tb = preload("res://tornado/tornado.tscn").instantiate(
			).init_sample(gc.aabb.size.x/2, gc.aabb.size.y*0.3, 0.5, RandomColorIter.get_and_next(),RandomColorIter.get_and_next())
		gc.add_child(tb)
		tornado_list.append([tb, AnimateGradient.new(), AnimateGradient.new()])
	return tornado_animate
func scale_tornado(rate):
	return Vector3(rate,1,rate)*rate
func shift_tornado_lambda(t :float, shift :float) -> Callable:
	return func(rate):
		var period := 5
		return Vector3(cos(rate*period), 0, sin(rate*period)) * t * shift

func tornado_animate(_delta :float) -> void:
	var t := Time.get_unix_time_from_system()
	var rad := fposmod(t, PI*2)
	var unit_rad := 2*PI/4
	for i in tornado_list.size():
		var gc :GlassCabinet = tornado_list[i][0].get_parent()
		var radius := gc.aabb.size.z/2
		var tt := t+ i
		tornado_list[i][0].set_transform_all(scale_tornado, shift_tornado_lambda( sin(tt), gc.aabb.size.x/10) )
		tornado_list[i][0].set_color_all(tornado_list[i][1].get_color(),tornado_list[i][2].get_color())
		tornado_list[i][1].inc_rate()
		tornado_list[i][2].inc_rate()
		tornado_list[i][0].position = Vector3(cos(i*unit_rad+t)*radius, sin(i*unit_rad+t*1.7)*radius/2 -gc.aabb.size.y/4, sin(i*unit_rad+t)*radius)
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
func wheel_demo(gc :GlassCabinet) -> Callable:
	gc.show_description()
	var color_text_into_list := make_color_text_info_list(
		colorlist_light, cardlist,
	).duplicate()
	color_text_into_list.shuffle()
	roulette = preload("res://roulette/roulette.tscn").instantiate(
		).init(0, gc.aabb.size.y/2, gc.aabb.size.z/20, color_text_into_list )
	roulette.색설정하기(RandomColorIter.get_and_next(), RandomColorIter.get_and_next(), RandomColorIter.get_and_next() )
	roulette.rotation_stopped.connect(wheel결과가결정됨)
	gc.add_child(roulette)
	wheel돌리기()
	return func (_delta :float) -> void:
		roulette.장식돌리기()
		roulette.선택된cell강조상태켜기()
func wheel돌리기() -> void:
	var rot = randfn(2*PI, PI/2)
	if randi_range(0,1) == 0:
		rot = -rot
	roulette.start_rotation.call_deferred(rot)
func wheel결과가결정됨(rl :Roulette) -> void:
	rl.get_parent().set_description_text(rl.선택된cell얻기().글내용얻기())
	$TimerWheel.start()
func _on_timer_wheel_timeout() -> void:
	wheel돌리기()


var slot :Slots
func slotreel_demo(gc :GlassCabinet) -> Callable:
	gc.show_description()
	var color_text_into_list := make_color_text_info_list(colorlist_dark, cardlist).duplicate()
	var symbol크기 := Vector2( gc.aabb.size.x/20, SlotReel.calc_symbol_ysize(gc.aabb.size.z/2, color_text_into_list.size() ) )
	slot = preload("res://slots/slots.tscn").instantiate().init(5, symbol크기, color_text_into_list)
	gc.add_child(slot)
	slot.rotation_stopped.connect(슬롯멈춤)
	slot.start_rotation()
	return Callable()
func 슬롯멈춤(sl :Slots) -> void:
	var symbol들 := sl.선택된symbol들얻기()
	var 결과 := ""
	for k in symbol들:
		결과 += k.글내용얻기() + " "
	sl.get_parent().set_description_text(결과)
	$TimerReel.start()
func _on_timer_reel_timeout() -> void:
	slot.start_rotation()


func wavegauge_box_demo(gc :GlassCabinet) -> Callable:
	var wavegauge_box :WaveGauge = preload("res://wave_gauge/wave_gauge.tscn").instantiate().init(
			Vector3(gc.aabb.size.x,gc.aabb.size.y,gc.aabb.size.z/4),
			Vector3i(32,32,8), WaveGauge.color_list, 0.1, false )
	gc.add_child(wavegauge_box)
	return func(_delta :float) -> void:
		wavegauge_box.animate_wave(Time.get_unix_time_from_system())




var trailmesh_radius :float
var meshtrail_list :Array
var bound_aabb :AABB
func meshtrail_demo(gc :GlassCabinet) -> Callable:
	trailmesh_radius = gc.aabb.size.length()/100
	bound_aabb = AABB( -gc.aabb.size/2, gc.aabb.size)
	var mesh := BoxMesh.new()
	mesh.material = MultiMeshShape.MakeMultiMeshColorMaterial()
	mesh.size = Vector3(trailmesh_radius*3, trailmesh_radius /5, trailmesh_radius/5)
	for i in 10:
		make_meshtrail(gc, i %4, mesh, 100, bound_aabb.get_center())
	return func (delta :float) -> void:
		for mt in meshtrail_list:
			mt.move_trail(delta, bounce_fn, trailmesh_radius, 4*PI,)
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

func props_demo(gc :GlassCabinet) -> Callable:
	var node3d_list :Array = []
	var grid_gc := gc.make_CalcGrid3D( Vector3i(5,3,1))
	var unit_size := grid_gc.unit_size
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	var prop
	prop = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(RandomColorIter.get_and_next()).set_size( unit_size.x *0.6, unit_size.x/30, unit_size.x/10, 0.3)
	afterfn.call(0, prop)
	prop = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(RandomColorIter.get_and_next()).set_size( unit_size.x *0.6, unit_size.x/30, unit_size.x/10, 0.7)
	afterfn.call(1, prop)
	prop = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(unit_size.x/6, unit_size.x/6, 8, RandomColorIter.get_and_next())
	afterfn.call(2, prop)
	prop = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(unit_size.x/6, unit_size.x/10, 4, RandomColorIter.get_and_next())
	afterfn.call(3, prop)
	prop = preload("res://axis_arrow_3d/axis_arrow_3d.tscn").instantiate(
		).set_colors().set_size(unit_size.length()/10)
	afterfn.call(4, prop)

	var grid_size := Vector2i(16,9)
	prop = preload("res://wire_net/wire_net.tscn").instantiate(
		).init(Vector2(unit_size.x,unit_size.y), grid_size, unit_size.x*0.01, unit_size.y*0.005, RandomColorIter.get_and_next())
	prop.set_color_H(RandomColorIter.get_and_next())
	prop.set_color_V(RandomColorIter.get_and_next())
	afterfn.call(5, prop)
	prop = preload("res://wire_net/wire_net.tscn").instantiate(
		).init(Vector2(unit_size.x,unit_size.y), grid_size, unit_size.x*0.01, unit_size.y*0.1, RandomColorIter.get_and_next())
	prop.set_color_H(RandomColorIter.get_and_next())
	prop.set_color_V(RandomColorIter.get_and_next())
	afterfn.call(6, prop)
	prop = preload("res://wire_net/wire_net.tscn").instantiate(
		).init(Vector2(unit_size.x,unit_size.y), Vector2i(16,1), unit_size.x*0.01, unit_size.y*0.1, RandomColorIter.get_and_next())
	prop.wire_V_rotation_y = PI/4
	afterfn.call(7, prop)

	for n in range(node3d_list.size(), grid_gc.get_grid_count()):
		var t4l :Table4Leg = preload("res://maze_3d/table_4_leg/table_4_leg.tscn").instantiate()
		var thick := unit_size.y/50
		t4l.init(
			Vector3(unit_size.x/2 * randfn(1,0.5), thick, unit_size.z/2 * randfn(1,0.5)),
			Vector3(thick,unit_size.y/4 * randfn(1,0.5), thick),
			RandomColorIter.get_and_next(),RandomColorIter.get_and_next())
		afterfn.call(n, t4l)

	return AnimateList.new().init_rotate(node3d_list)

func plot3d_image_demo(gc :GlassCabinet) -> Callable:
	gc.show_wall_box(false)
	var node3d_list :Array = []
	var grid_gc := gc.make_CalcGrid3D( Vector3i(4,2,1))
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	var p3_inst := preload("res://plot_3d/plot_3d.tscn").instantiate
	var tg_size := grid_gc.unit_size
	tg_size.z /= 50
	afterfn.call(0, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/vscode.png"), 0.9) )
	afterfn.call(1, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/git.png"), 0.9) )
	afterfn.call(2, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/github.png"), 0.9) )
	afterfn.call(3, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/me.png"), 0.9) )
	afterfn.call(4, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/firefox.png"), 0.9) )
	afterfn.call(5, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/gimp.png"), 0.9) )
	afterfn.call(6, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/blender.png"), 0.9) )
	afterfn.call(7, p3_inst.call().init_plot3d_by_texture2d_face_z(tg_size, preload("res://image/godot.png"), 0.9) )
	#return Callable()
	return AnimateList.new().init_rotate(node3d_list)

func plot3d_grid_demo(gc :GlassCabinet) -> Callable:
	var node3d_list :Array = []
	var grid_gc := gc.make_CalcGrid3D( Vector3i(3,2,1))
	var afterfn := func(n :int, node3d :Node3D) -> Node3D:
		node3d.position = grid_gc.get_n_th_lanepos(n)
		gc.add_child(node3d)
		node3d_list.append(node3d)
		return node3d
	var tg_inst := preload("res://plot_3d/plot_3d.tscn").instantiate
	var prop_size := Vector3(grid_gc.unit_size.x, grid_gc.unit_size.y, grid_gc.unit_size.z/200)
	var prop_size2 := Vector3(grid_gc.unit_size.x, grid_gc.unit_size.y, grid_gc.unit_size.z/5)
	afterfn.call(0, tg_inst.call().init_plot3d_box(prop_size2, Vector3i(16,16,1), 0.5)).fill_all(Color.WHITE)

	var prop = afterfn.call(1, tg_inst.call().init_plot3d_plane(prop_size, Vector3i(16,9,1), 0.9)).fill_all(Color.WHITE)
	prop.cell_rotation_x = PI/2

	prop = afterfn.call(2, tg_inst.call().init_plot3d_sphere(prop_size, Vector3i(14,12,1), 1.5)).fill_all(Color.WHITE)
	prop.cell_rotation_z = PI/4

	prop = afterfn.call(3, tg_inst.call().init_plot3d_cylinder(prop_size, Vector3i(14,12,1), 0.7, 6)).fill_all(Color.WHITE)
	prop.cell_rotation_x = PI/2

	prop = afterfn.call(4, tg_inst.call().init_plot3d_cylinder(prop_size, Vector3i(14,12,1), 0.7, 8)).fill_all(Color.WHITE)
	prop.cell_rotation_x = PI/2
	for i in prop.calc_grid.get_grid_count():
		prop.set_inst_rotate(i, Vector3.UP, PI/8)

	prop = afterfn.call(5, tg_inst.call().init_plot3d_cylinder(
		Vector3(grid_gc.unit_size.x, grid_gc.unit_size.y, grid_gc.unit_size.z/20),
		Vector3i(16,16,1), 0.8, 6)).fill_all(Color.WHITE)
	prop.calc_grid.iter_ixyz(func(index:int,xi:int,yi:int,zi:int):
		var pos :Vector3 = prop.calc_grid.posi_to_lanepos(Vector3i(xi,yi,zi))
		if yi % 2 == 1:
			pos += Vector3(prop.calc_grid.unit_size.x/2, 0, 0)
		prop.set_inst_position_rotation(index, pos, Vector3.RIGHT, PI/2)
		)

	var animation := SimpleAnimation.new()
	animation.animation_ended.connect(func(node :Node3D, _ani :Dictionary) -> void:
			AddRotateRandomAnimation(animation, node))
	for node in node3d_list:
		AddRotateRandomAnimation(animation, node)

	for ps in node3d_list:
		var now := randf_range(0,2*PI)
		WaveColorPlot3D(ps, now, ps.calc_grid.unit_size.length()/3 )

	return func(_delta:float):
		animation.handle_animation()


func line2d_demo(gc :GlassCabinet) -> Callable:
	var size_pixel := Vector2i(2048,2048)
	var ml2d = preload("res://move_line_2d/move_line_2d.tscn").instantiate()
	ml2d.init_with_random(300, 4, 1, size_pixel)
	var svp := MakeSubViewport(ml2d, size_pixel)
	var plane := MakePlaneSubViewport(svp, Vector2(gc.aabb.size.x, gc.aabb.size.y))
	gc.add_child(svp)
	gc.add_child(plane)
	return func(delta:float):
		ml2d.process_animation(delta)


var orbitsphere_list :Array
func orbit_demo(gc :GlassCabinet) -> Callable:
	for i in 9:
		add_orbitsphere(gc, i, 9)
	return func (delta :float) -> void:
		var now := Time.get_unix_time_from_system()
		for os in orbitsphere_list:
			os.animate_rotate(now, delta)
func add_orbitsphere(gc :GlassCabinet, i :int, count :int) -> void:
	var rate := float(count -i)/float(count) * 0.5 + 0.5
	var diagonal_length := gc.aabb.size.length()/2.5 * rate
	var a120 := PI*2/3
	var a30 := PI/6
	var axis1 := Vector3.UP.rotated(
		[Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK].pick_random(),
		randf_range(0,a30))
	var 궤도mat1 := StandardMaterial3D.new()
	궤도mat1.albedo_color = RandomColorIter.get_and_next()
	var 구mat2 :StandardMaterial3D
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
			구mat2.albedo_color = RandomColorIter.get_and_next()
	var os = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate(
		).궤도설정(diagonal_length, diagonal_length/200, axis1, a120*[0,1,2].pick_random()
		).구설정(gc.aabb.size.x/30*rate, gc.aabb.size.x/50, Vector3.UP
		).구재질설정(구mat2).궤도재질설정(궤도mat1)
	gc.add_child(os)
	orbitsphere_list.append(os)


func clock_calendar_demo(gc :GlassCabinet) -> Callable:
	var grid_gc := gc.make_CalcGrid3D( Vector3i(2,1,1))
	var calendar :Calendar3D= preload("res://calendar_3d/calendar_3d.tscn").instantiate(
		).init(gc.aabb.size.x/2, gc.aabb.size.y, gc.aabb.size.z/10, gc.aabb.size.y/2.0/6 , true )
	gc.add_child(calendar)
	#calendar.update_calendar(Calendar3D.make_unix_time(2026,3,7))
	var clock :AnalogClock3D= preload("res://analog_clock_3d/analog_clock_3d.tscn").instantiate(
		).init(gc.aabb.size.x/4, gc.aabb.size.z/10, gc.aabb.size.y/2.0/7 , true )
	gc.add_child(clock)

	var animation := SimpleAnimation.new()
	var pos_list := [grid_gc.get_n_th_lanepos(0), grid_gc.get_n_th_lanepos(1)]
	var rot_args := [ [0.0, 2*PI], [2*PI, 0.0] ]
	const ani_speed :float = 3
	clock.position = pos_list[0]
	calendar.position = pos_list[1]

	var start_animation := func():
		animation.start_move("clock",clock, pos_list[0], pos_list[1], ani_speed)
		animation.start_rotation_subfield("clock",clock, Vector3.Axis.AXIS_Y, rot_args[0][0] , rot_args[0][1], ani_speed)
		animation.start_move("clock",calendar, pos_list[1], pos_list[0], ani_speed)
		animation.start_rotation_subfield("clock",calendar, Vector3.Axis.AXIS_Y, rot_args[1][0], rot_args[1][1], ani_speed)
		pos_list.push_back( pos_list.pop_front()) # swap [pos_list[1], pos_list[0]]
		rot_args.push_back( rot_args.pop_front()) # swap [rot_args[1], rot_args[0]]
	var animation_ended := func(_node :Node3D, _ani :Dictionary) -> void:
		if animation.is_empty():
			start_animation.call()
	animation.animation_ended.connect(animation_ended)
	start_animation.call()
	return func(_delta:float):
		clock.update_clock(AnalogClock3D.get_localtime_from_system())
		animation.handle_animation()


var bartree_scene = preload("res://bar_tree/bar_tree.tscn")
var bartree_list :Array
func bartree_demo(gc :GlassCabinet) -> Callable:
	var tree_size := Vector3(gc.aabb.size.z/3, gc.aabb.size.y, gc.aabb.size.z / 30)
	make_tree3(randi_range(1,7), gc, tree_size, randi_range(20,100), Vector3(-gc.aabb.size.x/4,-gc.aabb.size.y/2,0), false)
	make_tree3(randi_range(1,7), gc, tree_size, randi_range(20,100), Vector3(gc.aabb.size.x/4,-gc.aabb.size.y/2,0), true)
	return func (delta :float) -> void:
		for bt in bartree_list:
			bt.rotate_tree_bar_y(delta*10)
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
		t.init_bartree_with_color(RandomColorIter.get_and_next(), RandomColorIter.get_and_next(), bar_count)
	t.init_bartree_transform(tree_size, shift)
	bartree_list.append(t)
