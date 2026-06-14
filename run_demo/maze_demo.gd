class_name MazeDemo

const WallDecoRate := 0.05
const MakeSubWallRate = 0.1

var maze3d :Maze3D
#var maze_balls :Array
var view_walls :Maze3D.WallPillarDoorView = Maze3D.WallPillarDoorView.WallShortPillarDoor
func maze3d_demo(gc :GlassCabinet) -> Callable:
	#gc.show_axis_arrow(true)
	var grid_size := Vector2i(16,9)*1
	var cell_size := Vector3(
		max(1,gc.aabb.size.x/grid_size.x),
		max(1,gc.aabb.size.y/grid_size.y),
		max(1,gc.aabb.size.y/grid_size.y),
	) * 0.95
	var WallThick = cell_size.x *0.1
	var maze2d := Maze.new(grid_size)

	var size_pixel :=Vector2(1920,1080)
	var minimap :MazeMiniMap = preload("res://maze_3d/maze_mini_map/maze_mini_map.tscn").instantiate()
	minimap.set_maze(maze2d)
	minimap.update_size(size_pixel)
	minimap.set_color(RunDemo.RandomColorIter.get_and_next())
	minimap.position.x = size_pixel.x/2 - minimap.maze2d_helper.get_width()/2
	var svp := RunDemo.MakeSubViewport(minimap, size_pixel)
	var plane := RunDemo.MakePlaneSubViewport(svp, Vector2(gc.aabb.size.x, gc.aabb.size.y))
	gc.add_child(svp)
	gc.add_child(plane)
	plane.position.z = -gc.aabb.size.z /2

	maze3d = preload("res://maze_3d/maze_3d.tscn").instantiate(
		).init_params(maze2d, cell_size, WallThick, MakeSubWallRate
		).init_with_color(RunDemo.RandomColorIter.get_and_next(), RunDemo.RandomColorIter.get_and_next(), RunDemo.RandomColorIter.get_and_next()
		#).init_floor_ceiling_box(Vector2i(4,4), cell_size.x*0.05, 0.9,
		).init_floor_ceiling_plane(Vector2i(1,1), cell_size.x*0.01, 0.9,
		Color(RunDemo.RandomColorIter.get_and_next(), 0.9),
		Color(RunDemo.RandomColorIter.get_and_next(), 0.9),
		)
	maze3d.make_door_by_maze(RunDemo.RandomColorIter.get_and_next(), RunDemo.RandomColorIter.get_and_next())
	maze3d.rotation.x = PI/4
	maze3d.view_floor_ceiling(Maze3D.FloorCeiling.Off)
	for i in 10:
		var posi := maze3d.calc_grid.rand_posi()
		maze3d.add_child(make_table4leg(Vector2i(posi.x,posi.z)))

	for i in 5:
		var posi_floor := maze3d.calc_grid.rand_posi()
		if randi() %2 ==0:
			maze3d.add_stair(posi_floor + Vector3i(0,-1,0), Maze.DirList.pick_random(), RunDemo.RandomColorIter.get_and_next())
		else:
			maze3d.add_ladder(posi_floor + Vector3i(0,-1,0), Maze.DirList.pick_random(), RunDemo.RandomColorIter.get_and_next())
		maze3d.make_stair_hole(maze3d.get_floor(), Vector2i(posi_floor.x, posi_floor.z) )
		var posi_ceiling := maze3d.calc_grid.rand_posi()
		if randi() %2 ==0:
			maze3d.add_stair(posi_ceiling , Maze.DirList.pick_random(), RunDemo.RandomColorIter.get_and_next())
		else:
			maze3d.add_ladder(posi_ceiling , Maze.DirList.pick_random(), RunDemo.RandomColorIter.get_and_next())
		maze3d.make_stair_hole(maze3d.get_ceiling(), Vector2i(posi_ceiling.x, posi_ceiling.z) )
	gc.add_child(maze3d)

	maze3d.maze_cells.iter_wall(add_wall_deco_at)

	#var r := maze3d.calc_grid.unit_size.x /10
	#for i in min(100,grid_size.x*grid_size.y):
		#var mb :MazeBall = preload("res://maze_3d/maze_ball/maze_ball.tscn").instantiate(
			#).init(maze3d, r, r*10,  RunDemo.RandomColorIter.get_and_next())
		#maze3d.add_child(mb)
		#maze_balls.append(mb)
	return maze3d_animate

func make_table4leg(posi :Vector2i) -> Table4Leg:
	var unit_size := maze3d.calc_grid.unit_size - Vector3(maze3d.WallThick, 0, maze3d.WallThick)
	var t4l :Table4Leg = preload("res://maze_3d/table_4_leg/table_4_leg.tscn").instantiate()
	var thick := unit_size.y/50
	t4l.init(
		Vector3(unit_size.x * randf_range(0.2,1.0), thick, unit_size.z * randf_range(0.2,1.0)),
		Vector3(thick, unit_size.y * randf_range(0.1,0.5) , thick),
		RunDemo.RandomColorIter.get_and_next(),RunDemo.RandomColorIter.get_and_next())
	var aabb := maze3d.calc_grid.cell_aabb_by_posi( Vector3i(posi.x, 0, posi.y) ).grow(-maze3d.WallThick)
	t4l.position = Vector3(
		CalcGrid3D.CalcAxisAlignInner(aabb, t4l.aabb.size, 0, randi_range(-1,1) ),
		CalcGrid3D.CalcAxisAlignInner(aabb, t4l.aabb.size, 1, -1 )-maze3d.WallThick/2,
		CalcGrid3D.CalcAxisAlignInner(aabb, t4l.aabb.size, 2, randi_range(-1,1) )
		)
	return t4l

var line2d_subviewport :SubViewport
var minimap_subviewport :SubViewport
## add wall deco
var wall_deco_order := ListIter.new(range(5))
func add_wall_deco_at(x :int, y :int, dir_flag :Maze.Flag) -> void:
	if randf() < WallDecoRate:
		match wall_deco_order.get_and_next():
			0:
				if line2d_subviewport == null:
					line2d_subviewport = make_line2d_subvuewport(Vector2i(2000,1500))
					maze3d.add_child(line2d_subviewport)
				var b := RunDemo.MakePlaneSubViewport(line2d_subviewport, Vector2(maze3d.calc_grid.unit_size.x, maze3d.calc_grid.unit_size.y))
				maze3d.add_child(b)
				b.position = maze3d.wall_deco_pos_by_dir(x,y,dir_flag)
				#b.rotate_x(PI/2)
				b.rotate_y(Maze.DirToRadian(Maze.FlagToDir[dir_flag]))
			1:
				if minimap_subviewport == null:
					minimap_subviewport = make_minimap_subvuewport(Vector2i(2000,1500))
					maze3d.add_child(minimap_subviewport)
				var b := RunDemo.MakePlaneSubViewport(minimap_subviewport, Vector2(maze3d.calc_grid.unit_size.x, maze3d.calc_grid.unit_size.y))
				maze3d.add_child(b)
				b.position = maze3d.wall_deco_pos_by_dir(x,y,dir_flag)
				#b.rotate_x(PI/2)
				b.rotate_y(Maze.DirToRadian(Maze.FlagToDir[dir_flag]))
			2:
				var depth := 0.1
				var 크기기준 :float = min(maze3d.calc_grid.unit_size.x, maze3d.calc_grid.unit_size.y,maze3d.calc_grid.unit_size.z)
				var n :Node3D = preload("res://calendar_3d/calendar_3d.tscn").instantiate()
				n.init(maze3d.calc_grid.unit_size.x, maze3d.calc_grid.unit_size.y, depth, 크기기준/12, false)
				#n.rotate_x(PI/2)
				n.rotate_y(Maze.DirToRadian(Maze.FlagToDir[dir_flag]))
				n.position = maze3d.wall_deco_pos_by_dir(x,y,dir_flag)
				maze3d.add_child(n)
			3:
				var depth := 0.1
				var 크기기준 :float = min(maze3d.calc_grid.unit_size.x, maze3d.calc_grid.unit_size.y,maze3d.calc_grid.unit_size.z)
				var n :Node3D = preload("res://analog_clock_3d/analog_clock_3d.tscn").instantiate()
				n.init(크기기준/2, depth, 크기기준/16, false)
				#n.rotate_x(PI/2)
				n.rotate_y(Maze.DirToRadian(Maze.FlagToDir[dir_flag]))
				n.position = maze3d.wall_deco_pos_by_dir(x,y,dir_flag)
				maze3d.add_child(n)
				n.update_clock(AnalogClock3D.get_localtime_from_system())
			4: # make bookcase
				var n :Node3D = preload("res://wire_net/wire_net.tscn").instantiate()
				var net_size := Vector2(maze3d.calc_grid.unit_size.x-maze3d.WallThick*2,maze3d.calc_grid.unit_size.y)
				n.init(
					net_size,
					Vector2i(4,8),
					maze3d.WallThick /4, maze3d.WallThick*2 ,
					RunDemo.RandomColorIter.get_and_next(),
					)
				#print_debug(net_size, n.size)
				n.rotate_y(Maze.DirToRadian(Maze.FlagToDir[dir_flag]))
				var wall_shift := Maze.FlagToVt2[dir_flag]*maze3d.WallThick/2
				n.position = maze3d.wall_deco_pos_by_dir(x,y,dir_flag) - Vector3(wall_shift.x,0,wall_shift.y)
				maze3d.add_child(n)

var move_line_2d_list :Array = []
func make_line2d_subvuewport(size_pixel:Vector2i) -> SubViewport:
	var l2d :MoveLine2D = preload("res://move_line_2d/move_line_2d.tscn").instantiate().init_with_random(300,4,1.5,size_pixel)
	move_line_2d_list.append(l2d)
	return  RunDemo.MakeSubViewport(l2d,size_pixel)

func make_minimap_subvuewport(size_pixel:Vector2i) -> SubViewport:
	var mm :MazeMiniMap = preload("res://maze_3d/maze_mini_map/maze_mini_map.tscn").instantiate()
	mm.set_maze(maze3d.maze_cells)
	mm.set_color(Color.WHITE)
	mm.update_size(size_pixel)
	mm.position = size_pixel as Vector2 /2  - mm.maze2d_helper.get_size()/2
	return  RunDemo.MakeSubViewport(mm,size_pixel)

var maze_ani_i :int
func maze3d_animate(delta :float) -> void:
	#for mb in maze_balls:
		#mb.bounce(delta)
	maze_ani_i += 1
	if maze_ani_i% 60 == 0:
		view_walls = Maze3D.wallpillardoorview_next(view_walls)
		maze3d.set_wallpillardoor_view_mode(view_walls)
		maze3d.view_floor_ceiling( randi_range(0,3) as Maze3D.FloorCeiling)
	maze3d.rotation.x = sin(deg_to_rad(maze_ani_i/1.5)) * PI + PI + PI/4
