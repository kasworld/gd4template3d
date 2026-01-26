extends Node3D
class_name SnakeByte

static var cabinet_size :Vector3
static var tile_size :Vector3

static func pos2d_to_pos3d( x :int, y :int, z :float = 0) -> Vector3:
	return Vector3(
		float(x) * tile_size.x - cabinet_size.x/2 + tile_size.x/2,
		float(y) * tile_size.y - cabinet_size.y/2 + tile_size.y/2,
		z)
static func pos3d_to_pos2d( pos :Vector3 ) -> Vector2i:
	return Vector2i(
		snappedi( (pos.x + cabinet_size.x/2 - tile_size.x/2) / tile_size.x ,1 ),
		snappedi( (pos.y + cabinet_size.y/2 - tile_size.y/2) / tile_size.y ,1 ),
	)

signal score_changed(점수 :float)
signal game_ended(game :SnakeByte)

static var FrameTime := 0.2 # second
static var SnakeLenStart := 12
static var SankeLenInc := 12
static var PlumCount := 2
static var AppleCountPerStage := 10
static var AppleIncOnStepOver := 3
static var EatStepOverLimit := SBWalls.FieldSize.x + SBWalls.FieldSize.y
static var SnakeLife := 3
static var SnakeLifeIncOnStageClear := 1
static var ScorePerApple := 10

var game_info :Dictionary
var field :PlacedThings
var astar_grid :AStarGrid2D

var apple_made_count :int
var apple_eat_count :int
var apple_end_count :int
var snake :SBSnake
var snake_step_after_eat :int
var gauge :MultiMeshShape

func _to_string() -> String:
	return "SnakeByte%d %s" % [game_info]
func update_info() -> void:
	$AppleInfo.text = "apple %d/%d" % [apple_eat_count, apple_end_count]
	$SnakeInfo.text = "score:%d snake:%d" % [game_info.score, game_info.snake]
	var demomode := ""
	if game_info.demo_mode:
		demomode = "demo game"
	$StageInfo.text = "stage %d %s" % [game_info.stage_number, demomode]

func init(sz :Vector3) -> SnakeByte:
	cabinet_size = sz
	tile_size = Vector3(cabinet_size.x / SBWalls.FieldSize.x, cabinet_size.y / SBWalls.FieldSize.y, cabinet_size.y / SBWalls.FieldSize.y )

	$StageInfo.position = pos2d_to_pos3d(0, SBWalls.FieldSize.y, tile_size.z)
	$SnakeInfo.position = pos2d_to_pos3d(SBWalls.FieldSize.x / 2, SBWalls.FieldSize.y, tile_size.z)
	$AppleInfo.position = pos2d_to_pos3d(SBWalls.FieldSize.x -1, SBWalls.FieldSize.y, tile_size.z)
	$StageInfo.pixel_size = tile_size.y /24
	$SnakeInfo.pixel_size = tile_size.y /24
	$AppleInfo.pixel_size = tile_size.y /24
	$FrameTimer.wait_time = SnakeByte.FrameTime

	gauge = preload("res://multi_mesh_shape/multi_mesh_shape.tscn").instantiate(
		).init_bar_gauge_y(SnakeByte.EatStepOverLimit, Vector3(tile_size.x, cabinet_size.y, tile_size.z), Color.GREEN, Color.RED)
	gauge.position = pos2d_to_pos3d(SBWalls.FieldSize.x, 0)
	add_child(gauge)
	return self

func new_game(gameinfo :Dictionary) -> void:
	game_info = gameinfo
	start_stage()

func start_stage() -> void:
	apple_eat_count = 0
	apple_made_count = 0
	apple_end_count = SnakeByte.AppleCountPerStage
	update_info()
	new_snake()

func new_snake() -> SnakeByte:
	field = PlacedThings.new(SBWalls.FieldSize)
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i( Vector2i(0,0), SBWalls.FieldSize)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	$Walls.init(game_info.stage_number, field , astar_grid)
	field.set_at( SBWalls.StartPos, SBStart.new())

	for pl in $PlumContainer.get_children():
		pl.queue_free()
	for i in SnakeByte.PlumCount:
		add_plum(i)

	for n in $AppleContainer.get_children():
		n.queue_free()
	snake_step_after_eat = 0
	apple_made_count = apple_eat_count
	if is_all_apple_eaten():
		$Walls.open_goalpos()
	else:
		add_apple()
	update_info()

	if snake != null :
		snake.queue_free()
	snake = preload("res://snake_byte/snake/snake.tscn").instantiate()
	add_child(snake)
	snake.connect("eat_apple", snake_eat_apple)
	snake.connect("snake_dead", snake_die)
	snake.connect("tail_enter", snake_enter_complete)
	snake.connect("reach_goal", snake_reach_goal)
	snake.init(field, astar_grid)
	return self

func add_plum(i:int) -> void:
	var pos := field.find_empty_pos(10)
	assert(pos!=Vector2i(-1,-1), "fail to find empty pos in field")
	var pl :SBPlum = preload("res://snake_byte/plum/plum.tscn").instantiate(
		).init(field, astar_grid, pos , Dir8Lib.DiagonalList.pick_random(), i)
	$PlumContainer.add_child(pl)

func add_apple() -> void:
	apple_made_count +=1
	var ap :SBApple = preload("res://snake_byte/apple/apple.tscn").instantiate().init(field, apple_made_count)
	$AppleContainer.add_child(ap)

func snake_die() -> void:
	game_info.snake -= 1
	if game_info.snake > 0:
		new_snake.call_deferred()
	else:
		game_ended.emit(self)

func snake_reach_goal() -> void:
	game_info.snake += SnakeLifeIncOnStageClear
	game_info.stage_number += 1
	start_stage()

func snake_eat_apple(pos :Vector2i) -> void:
	var ap = field.get_at(pos)
	assert(ap is SBApple, "eat not apple %s %s" %[ ap, pos])
	ap.delete()
	ap.queue_free()
	apple_eat_count += 1
	game_info.score += SnakeByte.ScorePerApple
	score_changed.emit(game_info.score)
	snake_step_after_eat = 0
	update_info()
	if is_all_apple_eaten():
		$Walls.open_goalpos()
		return
	if $AppleContainer.get_child_count() <= 1:
		add_apple()

func is_all_apple_eaten() -> bool:
	return apple_eat_count >= apple_end_count

func snake_enter_complete() -> void:
	$Walls.close_startpos()


func process_frame() -> void:
	for p in $PlumContainer.get_children():
		p.move2d()
	if is_snake_alive():
		if game_info.demo_mode:
			demo_move_pathfinding()
		snake.process_frame()
		#if not is_all_apple_eaten():
		snake_step_after_eat += 1
		if snake_step_after_eat >= SnakeByte.EatStepOverLimit:
			handle_stepover()
		gauge.set_visible_count(snake_step_after_eat)
	else:
		gauge.set_visible_count(0)

func handle_stepover() -> void:
	snake_step_after_eat = 0
	if not is_all_apple_eaten():
		for i in SnakeByte.AppleIncOnStepOver:
			add_apple()
		apple_end_count += SnakeByte.AppleIncOnStepOver
		update_info()
	snake.dest_body_len += SnakeByte.SankeLenInc

func _on_frame_timer_timeout() -> void:
	process_frame()

func is_snake_alive() -> bool:
	return snake != null and snake.is_alive

#####################################################################
# ai move functions for demo
func get_next_apple_pos2i() -> Vector2i:
	return $AppleContainer.get_child(0).pos2d
func snake_head_pos2i() -> Vector2i:
	return snake.pos2d_list[0]
func snake_next_pos2i() -> Vector2i:
	return snake.get_next_head_pos()
func can_turn(from :Dir8Lib.Dir, to :Dir8Lib.Dir) -> bool:
	return from != Dir8Lib.DirOpposite(to)

func demo_move_pathfinding() -> void:
	if not is_snake_alive():
		return
	var id_path :Array[Vector2i]
	if is_all_apple_eaten():
		id_path = astar_grid.get_id_path(snake_head_pos2i() , SBWalls.GoalPos, true)
	else :
		id_path = astar_grid.get_id_path(snake_head_pos2i() , get_next_apple_pos2i(), true)
	if id_path.size() < 2:
		return
	var vt :Vector2i = sign(id_path[1] - snake_head_pos2i())
	snake.cmd_queue.append(Dir8Lib.Vt2Dir[vt])
