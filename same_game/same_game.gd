extends Node3D
class_name SameGame

signal score_changed(점수 :float)
signal game_ended(game :SameGame)

var color_list := [
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA,
	Color.WHITE,
	Color.BLACK,
]
var char_list := ["♥","♣","♠","♦","★","☆"]

var game_level :int
var cabinet_size :Vector3
var game_size := Vector2i(16,9)
var tile_size :Vector3
var calc_grid :CalcGrid3D
var co3d_grid :SamegameGrid # [x][y]
var 점수 :int

func init(sz :Vector3) -> SameGame:
	cabinet_size = sz
	calc_grid = CalcGrid3D.new( CalcGrid3D.SizeToAABB(cabinet_size), CalcGrid3D.xy_Vector2iToVector3i(game_size,1))
	tile_size = calc_grid.unit_size
	tile_size.z = tile_size.y
	SameGameTile.tile_size = tile_size
	SameGameTile.calc_pos_in_grid = calc_grid.lanepos_to_posi #  pos3d_to_pos2d
	return self

func new_game(lv:int) -> void:
	color_list.shuffle()
	char_list.shuffle()
	game_level = lv
	점수 = 0
	score_changed.emit(점수)
	for n in $CO3DContainer.get_children():
		n.queue_free()
	add_co3d()

var move_ani := SimpleAnimation.new()
func fix_gridco3d_pos_all() -> void:
	for x in co3d_grid.grid_size.x:
		for y in co3d_grid.grid_size.y:
			var co3d = co3d_grid.get_data(x,y)
			if co3d != null:
				move_ani.start_move("move", co3d, co3d.position, calc_grid.posi_to_lanepos(Vector3i(x,y,0)) , 0.5)

var auto_play :bool = true
var auto_play_selected :CollisionObject3D
var auto_play_last_time :float
const auto_play_step_dur_sec := 1.0
func set_auto_play(b :bool) -> void:
	auto_play = b
func auto_play_select_animate_tile() -> void:
	var data_dict := co3d_grid.get_pos_to_data_dict()
	if data_dict.is_empty():
		return
	auto_play_selected = data_dict.values().pick_random()
	co3d_mouse_entered(auto_play_selected)
func auto_play_selected_tile() -> void:
	assert(auto_play_selected != null)
	co3d_mouse_pressed(auto_play_selected)
	auto_play_selected = null


func _process(_delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	if (now-auto_play_last_time)> auto_play_step_dur_sec and auto_play:
		auto_play_last_time = now
		if auto_play_selected == null:
			auto_play_select_animate_tile()
		else:
			auto_play_selected_tile()
	move_ani.handle_animation()

func add_co3d() -> void:
	co3d_grid = SamegameGrid.new( game_size.x , game_size.y )
	var tile_type_count :int = (game_level % char_list.size())+1
	for x :int in game_size.x:
		for y :int in game_size.y:
			var co3d_num = randi_range(0,tile_type_count)
			var b = preload("res://same_game/same_game_tile/same_game_tile.tscn").instantiate().set_type_num(co3d_num
				).set_char(char_list[co3d_num]
				).set_color( color_list[co3d_num] )
			b.position = calc_grid.posi_to_lanepos(Vector3i(x,y,0))
			b.co3d_mouse_entered.connect(co3d_mouse_entered)
			b.co3d_mouse_exited.connect(co3d_mouse_exited)
			b.co3d_mouse_pressed.connect(co3d_mouse_pressed)
			$CO3DContainer.add_child(b)
			co3d_grid.set_data(x, y, b)

var selected_co3d_list :Array[CollisionObject3D]
func co3d_mouse_entered(b :CollisionObject3D) -> void:
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()
	selected_co3d_list = find_sameballs(b)
	for n in selected_co3d_list:
		n.start_animation()

func co3d_mouse_exited(_b :CollisionObject3D) -> void:
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()

func co3d_mouse_pressed(b :CollisionObject3D) -> void:
	var co3d_list = find_sameballs(b)
	점수 += pow(co3d_list.size(), 2) as int
	score_changed.emit(점수)
	for n in co3d_list:
		var p2d := calc_grid.lanepos_to_posi(n.position)
		co3d_grid.set_data(p2d.x,p2d.y, null)
		n.queue_free()
	if co3d_grid.count_data() == 0:
		score_changed.emit(점수)
		game_ended.emit(self)
		return
	co3d_grid.fill_down()
	co3d_grid.fill_left()
	fix_gridco3d_pos_all()

func find_sameballs(b :CollisionObject3D) -> Array[CollisionObject3D]:
	var found_balls :Array[CollisionObject3D] = []
	var visited_pos :Dictionary[Vector2i,bool] # vector2i
	var to_visit_pos :Array[Vector2i] # vector2i
	to_visit_pos.append( CalcGrid3D.xy_Vector3iToVector2i(calc_grid.lanepos_to_posi(b.position) ) )
	while not to_visit_pos.is_empty():
		var current_pos = to_visit_pos.pop_front()
		if visited_pos.has(current_pos):
			continue
		visited_pos[current_pos] = true
		var current_ball = co3d_grid.grid_data[current_pos.x][current_pos.y]
		if current_ball == null:
			continue
		if current_ball.type_num == b.type_num:
			found_balls.append(current_ball)
			for dir in co3d_grid.dir_list:
				var to_pos = current_pos + dir
				if to_pos.x < 0 or to_pos.x >= co3d_grid.grid_size.x or to_pos.y < 0 or to_pos.y >= co3d_grid.grid_size.y:
					continue
				if co3d_grid.grid_data[current_pos.x][current_pos.y] == null:
					continue
				if visited_pos.has(to_pos) :
					continue
				to_visit_pos.append(to_pos)
	return found_balls
