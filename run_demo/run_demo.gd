extends Node3D
class_name RunDemo

var glass_cabinet_iter :ListIter # [ GlassCabinet, light iter data]
var used_glass_cabinet_iter :ListIter
var empty_glass_cabinet_iter :ListIter


var animate_func_list :Array[Callable] = []
func init(cabinet_list :Array, add_camera_dict :Callable, run1 :Array =[]) -> void:
	var gc_ani_list := []
	for gc in cabinet_list:
		gc_ani_list.append([gc, AnimateGradient.new(),AnimateGradient.new()])
	glass_cabinet_iter = ListIter.new(gc_ani_list, true)

	var run_demo := func(demo :Callable, text :String) -> void:
		var gc :GlassCabinet = glass_cabinet_iter.get_current_and_step_next()[0]
		var ani_fn :Callable = demo.call(gc)
		if not ani_fn.is_null():
			animate_func_list.append(ani_fn)
		gc.set_title_text(text)
		add_camera_dict.call(gc.get_camera_light(), text)

	var run_all := [
		[bartree_demo, "BarTree"],
		[clock_calendar_demo, "Clock Calender"],
		[orbit_demo, "Orbit"],
		[line2d_demo, "MoveLine2d"],
		[meshtrail_demo, "MeshTrail"],
		[maze3d_demo, "Maze3D"],
		[slotreel_demo, "SlotReel"],
		[wheel_demo, "RouletteWheel" ],
		[props_demo, "Props"],
		[wavegauge_box_demo, "WaveGaugeBox"],
		[tornado_demo, "Tornado"],
		[platonic_solids_demo, "Platonic Solids"],
		[winter_tree_demo, "Winter Tree"],
		[dialgauge_demo, "Dial Gauge"],
		[same_game_demo, "Same Game"],
		[snakebyte_demo, "Snakebyte Game"],
		[ladder_demo, "사다리게임"],
		[yutgame_demo, "윷놀이"],
		[battle_shooter_demo, "Battle Shooter"],
		[tetromino_demo, "Tetromino"],
	]
	if not run1.is_empty():
		run_all = [ run1 ]
	for run in run_all:
		run_demo.call(run[0], run[1])

	used_glass_cabinet_iter = ListIter.new(glass_cabinet_iter.get_itered_slice())
	empty_glass_cabinet_iter = ListIter.new(glass_cabinet_iter.get_unitered_slice())
	print_debug("remain glass cabinet %d\ndemo count %s" % [
		empty_glass_cabinet_iter.get_size(),used_glass_cabinet_iter.get_size() ])

func animate_empty_glass_cabinet_light() -> void:
	if not empty_glass_cabinet_iter:
		return
	var lai :Array = empty_glass_cabinet_iter.get_current_and_step_next()
	var gc :GlassCabinet = lai[0]
	for i in lai.slice(1).size():
		var flags :=  GlassCabinet.GroupFlags[ GlassCabinet.GroupFlags.keys()[i] ]
		var ani_state :AnimateGradient = lai.slice(1)[i]
		gc.set_light_color(ani_state.get_color(), flags)
		ani_state.inc_rate(0.1)

func animate_used_glass_cabinet_light() -> void:
	if not used_glass_cabinet_iter:
		return
	var lai :Array = used_glass_cabinet_iter.get_current_and_step_next()
	var gc :GlassCabinet = lai[0]
	for i in lai.slice(1).size():
		var flags :=  GlassCabinet.GroupFlags[ GlassCabinet.GroupFlags.keys()[i] ]
		var ani_state :AnimateGradient = lai.slice(1)[i]
		gc.set_light_color(ani_state.get_color(), flags)
		ani_state.inc_rate(0.1)

func _process(delta: float) -> void:
	animate_empty_glass_cabinet_light()
	#animate_used_glass_cabinet_light()
	for fn in animate_func_list:
		fn.call(delta)


var tetromino_iter :ListIter
func tetromino_demo(gc :GlassCabinet) -> Callable:
	gc.show_description()
	gc.show_wall_box(false)
	var grid_size := Vector2i(32,18)
	var calc_grid := CalcGrid3D.new(gc.get_aabb(),CalcGrid3D.xy_Vector2iToVector3i(grid_size,1))
	var tetromino_list :Array = []
	for t in Tetromino.Type.size():
		var tetromino :Tetromino = preload("res://polyomino/tetromino/Tetromino.tscn").instantiate(
			).init(t, 0, calc_grid.unit_size.x)
		gc.add_child(tetromino)
		tetromino.position = calc_grid.get_n_th_lanepos( randi_range(0, calc_grid.get_grid_count()-1) )
		tetromino_list.append(tetromino)
	tetromino_iter = ListIter.new(tetromino_list)
	return func(_delta :float) -> void:
		var tet :Tetromino = tetromino_iter.get_current_and_step_next()
		if tet.animation.is_empty():
			var n := randi_range(0,7)
			match n:
				0,1,2,3,4,5:
					var dir :Vector3 = [Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK][n]
					tet.animate_rotation_to_dir(dir)
					if dir.z == 0:
						var dstpos := tet.position + dir*calc_grid.unit_size
						if calc_grid.has_point(dstpos):
							tet.animate_move_to( dstpos )
				6:
					tet.animate_morph_to(tet.tetromino_type, tet.get_right_rotation())
				7:
					tet.animate_morph_to(tet.tetromino_type, tet.get_left_rotation())


var battleshooter :BattleShooter
func battle_shooter_demo(gc :GlassCabinet) -> Callable:
	#gc.set_light_shadow(true, GlassCabinet.BitFlagAllLight)
	gc.show_description()
	var sz := gc.cabinet_size
	battleshooter = preload("res://battle_shooter_3d/battle_shooter.tscn").instantiate(
		).init(sz)
	gc.add_child(battleshooter)
	return Callable()


var yutgame :윷놀이
func yutgame_demo(gc :GlassCabinet) -> Callable:
	gc.show_wall_box(false)
	yutgame = preload("res://윷놀이/윷놀이.tscn").instantiate().init(gc.cabinet_size)
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
	gc.show_wall_box(false)
	var 참가자정보 :Array
	for i in 8:
		참가자정보.append( ["출발%d" % [i+1], 밝은색목록.get_current_and_step_next(), "도착%d" % [i+1] ] )
	ladder = preload("res://사다리게임/사다리게임.tscn").instantiate(
		).init(gc.cabinet_size, 참가자정보)
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
	gc.show_wall_box(false)
	#gc.lights.set_light_energy(10, BitFlag.MakeFilledFlags( $GlassCabinet.lights.get_size() ))
	snake_byte_game = preload("res://snake_byte/snake_byte.tscn").instantiate(
		).init(gc.cabinet_size)
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
		).init(gc.cabinet_size)
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
		).init(radius, cabinet_size.z/20, NamedColors.random_color(),NamedColors.random_color(),NamedColors.random_color(),
		).init_range( make_rand_range(0,360), make_rand_range(0,2*PI)
		).add_dial_num(radius*0.80, cabinet_size.z/100, radius/20, 12, NamedColors.random_color(),
		).add_dial_bar(radius*0.92, Vector3(cabinet_size.z/40, cabinet_size.z/200, cabinet_size.z/100),
			DialGauge.BarAlign.Out, 60, NamedColors.random_color()
		).add_dial_bar(radius*0.92, Vector3(cabinet_size.z/40, cabinet_size.z/200, cabinet_size.z/100),
			DialGauge.BarAlign.In, 12, NamedColors.random_color()
		)
var dialgauge_list :Array
func dialgauge_demo(gc :GlassCabinet) -> Callable:
	#gc.show_wall_box(false)
	var radius := gc.cabinet_size.x/5
	var grid21 := gc.make_CalcGrid3D(Vector3i(2,1,1))
	var grid33 := gc.make_CalcGrid3D(Vector3i(3,3,1))
	var dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = grid21.posi_to_lanepos(Vector3i(0,0,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = grid21.posi_to_lanepos(Vector3i(1,0,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	radius = gc.cabinet_size.x/10
	dg = new_dialgauge(radius, gc.cabinet_size)
	dg.position = grid33.posi_to_lanepos(Vector3i(1,0,0))
	gc.add_child(dg)
	dialgauge_list.append([dg, dg.value_range_mid()])
	dg = new_dialgauge(radius, gc.cabinet_size)
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
		).init(gc.cabinet_size.y, gc.cabinet_size.z/2, gc.cabinet_size.y*2, PI, 1.0,
		).set_center_color(Color.GREEN)
	gc.add_child(winter_tree)
	#$"왼쪽패널/LabelTree".text = "branch count %d" % [ winter_tree.가지들얻기().multimesh.instance_count ]
	winter_tree.position.y = -gc.cabinet_size.y/2
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
	winter_tree.장식들얻기().set_inst_color( randi_range(0, winter_tree.장식들얻기().multimesh.instance_count-1),  NamedColors.random_color())

	if ani_ended:
		color_fn_args.get_current_and_step_next()
		ani_dir_data.get_current_and_step_next()
		change_count = 0
		color_fn = [RandomColor.pure_color, RandomColor.rate_color, random_color2].pick_random()
		winter_tree.장식들얻기().set_color_all( NamedColors.random_color())

var named_color_list := ListIter.new(NamedColors.color_list)
func random_color2(_arg ) -> Color:
	return named_color_list.get_current_and_step_next()


var platonic_solid_list :Array = []
func platonic_solids_demo(gc :GlassCabinet) -> Callable:
	#gc.show_wall_box(false)
	var grid43 := gc.make_CalcGrid3D(Vector3i(4,3,1))
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
		var wire_width :float = ll[1] * gc.cabinet_size.length() /300
		var from :int = ll[2]
		var to :int = ll[3]
		var ws :WireSolid = preload("res://wire_solid/wire_solid.tscn").instantiate(
			).init(face, from, to, grid43.unit_size.y/2-wire_width , wire_width, NamedColors.random_color(), wire_width )
		gc.add_child(ws)
		platonic_solid_list.append(ws)
		ws.position = grid43.get_n_th_lanepos(i)
		i +=1
	platonic_solids_animation.animation_ended.connect(platonic_solids_animation_ended)
	start_platonic_solids_animation()
	return func(_delta:float):
		platonic_solids_animation.handle_animation()

var platonic_solids_animation := SimpleAnimation.new()
func platonic_solids_animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	if platonic_solids_animation.is_empty():
		start_platonic_solids_animation()
func start_platonic_solids_animation() -> void:
	for ps in platonic_solid_list:
		var diff :float = [PI/2,-PI/2].pick_random()
		var axis :int = [Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random()
		platonic_solids_animation.start_rotation_subfield(
			"ani_rot", ps, axis , ps.rotation[axis], ps.rotation[axis] + diff, 1.0)


var tornado_list :Array # [ tornado , AnimateGradient , AnimateGradient ]
func tornado_demo(gc :GlassCabinet) -> Callable:
	#gc.show_wall_box(false)
	for i in 4:
		var tb = preload("res://tornado/tornado.tscn").instantiate(
			).init_sample(gc.cabinet_size.x/2, gc.cabinet_size.y*0.3, 0.5, NamedColors.random_color(),NamedColors.random_color())
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
		var radius := gc.cabinet_size.z/2
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
func wheel_demo(gc :GlassCabinet) -> Callable:
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
	var symbol크기 := Vector2( gc.cabinet_size.x/20, SlotReel.calc_symbol_ysize(gc.cabinet_size.z/2, color_text_into_list.size() ) )
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


var wavegauge_box :WaveGauge
func wavegauge_box_demo(gc :GlassCabinet) -> Callable:
	wavegauge_box = preload("res://wave_gauge/wave_gauge.tscn").instantiate(
		).init(Vector3(gc.cabinet_size.x-1,gc.cabinet_size.y-1,gc.cabinet_size.z-1), Vector3i(32,32,32), WaveGauge.color_list, 0.1, 1.0 )
	gc.add_child(wavegauge_box)
	return func(_delta :float) -> void:
		wavegauge_box.animate_wave(Time.get_unix_time_from_system())


var maze3d :Maze3D
var maze_balls :Array
var view_walls :Maze3D.WallPillarView = Maze3D.WallPillarView.ShortWithPillarCapsule
func maze3d_demo(gc :GlassCabinet) -> Callable:
	#gc.show_axis_arrow(true)
	#gc.show_wall_box(false)
	var grid_size := Vector2i(16,9)*1
	var cell_size := Vector3(
		max(1,gc.cabinet_size.x/grid_size.x),
		max(1,gc.cabinet_size.y/grid_size.y),
		max(1,gc.cabinet_size.y/grid_size.y),
	) * 0.95
	var WallThick = cell_size.x *0.1
	var MakeSubWallRate = 0.1
	maze3d = preload("res://maze_3d/maze_3d.tscn").instantiate(
		).init_setting(grid_size, cell_size, WallThick, MakeSubWallRate
		).init_with_color(Callable(), NamedColors.random_color(), NamedColors.random_color(), NamedColors.random_color(), NamedColors.random_color()
		).init_floor_ceiling(grid_size*4, cell_size.x*0.01,cell_size.x*0.01,
		Color(NamedColors.random_color(), 0.9),
		Color(NamedColors.random_color(), 0.9))
	maze3d.rotation.x = PI/4
	maze3d.view_floor_ceiling(Maze3D.FloorCeiling.Both)
	gc.add_child(maze3d)
	var r := maze3d.calc_grid.unit_size.x /10
	for i in min(100,grid_size.x*grid_size.y):
		var mb :MazeBall = preload("res://maze_3d/maze_ball/maze_ball.tscn").instantiate(
			).init(maze3d, r, r*10,  NamedColors.random_color())
		maze3d.add_child(mb)
		maze_balls.append(mb)
	return maze3d_animate
var maze_ani_i :int
func maze3d_animate(delta :float) -> void:
	for mb in maze_balls:
		mb.bounce(delta)
	#return
	maze_ani_i += 1
	if maze_ani_i% 60 == 0:
		view_walls = Maze3D.wallview_next(view_walls)
		#if view_walls != Maze3D.WallPillarView.ShortWithPillarCapsule and view_walls != Maze3D.WallPillarView.OffWithPillarCapsule:
		maze3d.set_wallpillar_view_mode(view_walls)
		maze3d.view_floor_ceiling( randi_range(0,3) as Maze3D.FloorCeiling)
	maze3d.rotation.x = sin(deg_to_rad(maze_ani_i/1.5)) * PI + PI + PI/4


var trailmesh_radius :float
var meshtrail_list :Array
var bound_aabb :AABB
func meshtrail_demo(gc :GlassCabinet) -> Callable:
	trailmesh_radius = gc.cabinet_size.length()/100
	bound_aabb = AABB( -gc.cabinet_size/2, gc.cabinet_size)
	var mesh := BoxMesh.new()
	mesh.material = MultiMeshShape.make_color_material()
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
	var prop_list :Array
	var grid32 := gc.make_CalcGrid3D( Vector3i(5,3,1))
	var afterfn := func(pr, x,y):
		pr.position = grid32.posi_to_lanepos(Vector3i(x,y,0))
		gc.add_child(pr)
		prop_list.append(pr)

	var prop = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(NamedColors.random_color()).set_size( grid32.unit_size.x *0.6, grid32.unit_size.x/30, grid32.unit_size.x/10, 0.3)
	afterfn.call(prop,0,0)
	prop = preload("res://arrow_3d/arrow_3d.tscn").instantiate(
		).set_color(NamedColors.random_color()).set_size( grid32.unit_size.x *0.6, grid32.unit_size.x/30, grid32.unit_size.x/10, 0.7)
	afterfn.call(prop,4,0)
	prop = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(grid32.unit_size.x/6, grid32.unit_size.x/6, 8, NamedColors.random_color())
	afterfn.call(prop,0,2)
	prop = preload("res://valve_handle/valve_handle.tscn").instantiate(
		).init(grid32.unit_size.x/6, grid32.unit_size.x/10, 4, NamedColors.random_color())
	afterfn.call(prop,4,2)
	prop = preload("res://axis_arrow_3d/axis_arrow_3d.tscn").instantiate(
		).set_colors().set_size(grid32.unit_size.length()/10)
	afterfn.call(prop,2,1)

	var grid_size := Vector2i(16,9)
	prop = preload("res://wire_net/wire_net.tscn").instantiate(
		).init(Vector2(grid32.unit_size.x,grid32.unit_size.y), grid_size, grid32.unit_size.x*0.01, grid32.unit_size.y*0.005, NamedColors.random_color())
	prop.set_color_H(NamedColors.random_color())
	prop.set_color_V(NamedColors.random_color())
	afterfn.call(prop,3,0)
	prop = preload("res://wire_net/wire_net.tscn").instantiate(
		).init(Vector2(grid32.unit_size.x,grid32.unit_size.y), grid_size, grid32.unit_size.x*0.01, grid32.unit_size.y*0.1, NamedColors.random_color())
	prop.set_color_H(NamedColors.random_color())
	prop.set_color_V(NamedColors.random_color())
	afterfn.call(prop,3,1)
	prop = preload("res://wire_net/wire_net.tscn").instantiate(
		).init(Vector2(grid32.unit_size.x,grid32.unit_size.y), Vector2i(16,1), grid32.unit_size.x*0.01, grid32.unit_size.y*0.1, NamedColors.random_color())
	prop.wire_V_rotation_y = PI/4
	afterfn.call(prop,3,2)

	prop = preload("res://tile_grid/tile_grid.tscn").instantiate(
		).init_tile_grid_with_box(
		Vector3(grid32.unit_size.x, grid32.unit_size.y, grid32.unit_size.z/200),
		Vector2i(16,9), 0.9, Color.WHITE, )
	for i in prop.get_visible_count():
		prop.set_inst_color(i, NamedColors.random_color())
	afterfn.call(prop, 1,0)
	prop = preload("res://tile_grid/tile_grid.tscn").instantiate(
		).init_tile_grid_with_plane(
		Vector3(grid32.unit_size.x, grid32.unit_size.y, grid32.unit_size.z/200),
		Vector2i(16,9), 0.9, Color.WHITE)
	for i in prop.get_visible_count():
		prop.set_inst_color(i, NamedColors.random_color())
	afterfn.call(prop, 1,1)
	prop = preload("res://tile_grid/tile_grid.tscn").instantiate(
		).init_tile_grid_with_sphere(
		Vector3(grid32.unit_size.x, grid32.unit_size.y, grid32.unit_size.z/200),
		Vector2i(16,9), 0.9, Color.WHITE)
	for i in prop.get_visible_count():
		prop.set_inst_color(i, NamedColors.random_color())
	afterfn.call(prop, 1,2)

	var props_animation := SimpleAnimation.new()
	var start_props_animation = func() -> void:
		for ps in prop_list:
			var diff :float = [PI/2,-PI/2].pick_random()
			var axis :int = [Vector3.Axis.AXIS_X, Vector3.Axis.AXIS_Y, Vector3.Axis.AXIS_Z].pick_random()
			props_animation.start_rotation_subfield(
				"ani_rot", ps, axis , ps.rotation[axis], ps.rotation[axis] + diff, 1.0)
			if ps is TileGrid:
				props_animation.add_animation( ps.make_ani_tile_rotate("", randi_range(0,2),  0.0, PI, 1.0))
			#if ps is WireNet:
				#props_animation.add_animation( ps.make_ani_rotate("", randi_range(0,1),  0.0, PI, 1.0))

	props_animation.animation_ended.connect(
		func(_node :Node3D, _ani :Dictionary) -> void:
			if props_animation.is_empty():
				start_props_animation.call())
	start_props_animation.call()
	return func(_delta:float):
		props_animation.handle_animation()



func line2d_demo(gc :GlassCabinet) -> Callable:
	gc.show_wall_box(false)
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
	return Callable()

var orbitsphere_list :Array
func orbit_demo(gc :GlassCabinet) -> Callable:
	#gc.show_wall_box(false)
	for i in 9:
		add_orbitsphere(gc, i, 9)
	return func (delta :float) -> void:
		var now := Time.get_unix_time_from_system()
		for os in orbitsphere_list:
			os.animate_rotate(now, delta)
func add_orbitsphere(gc :GlassCabinet, i :int, count :int) -> void:
	var rate := float(count -i)/float(count) * 0.5 + 0.5
	var diagonal_length := gc.cabinet_size.length()/2.5 * rate
	var a120 := PI*2/3
	var a30 := PI/6
	var axis1 := Vector3.UP.rotated(
		[Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK].pick_random(),
		a30)
	var 궤도mat1 := StandardMaterial3D.new()
	궤도mat1.albedo_color = NamedColors.random_color()
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
			구mat2.albedo_color = NamedColors.random_color()
	var os = preload("res://orbit_sphere/orbit_sphere.tscn").instantiate(
		).궤도설정(diagonal_length, diagonal_length/200, axis1, a120*[0,1,2].pick_random()
		).구설정(gc.cabinet_size.x/30*rate, gc.cabinet_size.x/50, Vector3.UP
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
	clock_calendar_animation.start_rotation_subfield("clock",clock, Vector3.Axis.AXIS_Y, clock_calendar_rot_args[0][0] , clock_calendar_rot_args[0][1], ani_speed)
	clock_calendar_animation.start_move("clock",calendar, clock_calendar_pos_list[1], clock_calendar_pos_list[0], ani_speed)
	clock_calendar_animation.start_rotation_subfield("clock",calendar, Vector3.Axis.AXIS_Y, clock_calendar_rot_args[1][0], clock_calendar_rot_args[1][1], ani_speed)
	clock_calendar_pos_list = [clock_calendar_pos_list[1], clock_calendar_pos_list[0]]
	clock_calendar_rot_args = [clock_calendar_rot_args[1], clock_calendar_rot_args[0]]

var calendar :Calendar3D
var clock :AnalogClock3D
func clock_calendar_demo(gc :GlassCabinet) -> Callable:
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
	return func(_delta:float):
		clock_calendar_animation.handle_animation()


var bartree_scene = preload("res://bar_tree/bar_tree.tscn")
var bartree_list :Array
func bartree_demo(gc :GlassCabinet) -> Callable:
	var tree_size := Vector3(gc.cabinet_size.z/3, gc.cabinet_size.y, gc.cabinet_size.z / 30)
	make_tree3(randi_range(1,7), gc, tree_size, randi_range(20,100), Vector3(-gc.cabinet_size.x/4,-gc.cabinet_size.y/2,0), false)
	make_tree3(randi_range(1,7), gc, tree_size, randi_range(20,100), Vector3(gc.cabinet_size.x/4,-gc.cabinet_size.y/2,0), true)
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
		t.init_bartree_with_color(NamedColors.random_color(), NamedColors.random_color(), bar_count)
	t.init_bartree_transform(tree_size, shift)
	bartree_list.append(t)
