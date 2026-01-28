extends Node3D
class_name TourCamera

var wait_btw_animation := 1.0
var animation_dur := 1.0

var animation_queue :Array # [ [ move, rotate, fov, far ], [keep following move, rotate] ]
var tour_animation :SimpleAnimation

func _init() -> void:
	animation_queue = []
	tour_animation = SimpleAnimation.new()
	tour_animation.animation_ended.connect(animation_ended)

func init_by_glass_cabinet_list(gc_list :Array[GlassCabinet]) -> TourCamera:
	for i in gc_list.size():
		enqueue(get_camera_from_glass_cabinet(gc_list[i]), get_camera_from_glass_cabinet(gc_list[(i+1)%gc_list.size()]) )
	return self
func get_camera_from_glass_cabinet(gc :GlassCabinet) -> Camera3D:
	return gc.get_camera_light().get_camera()

func init_by_moving_camera_light_list(mcl_list :Array[MovingCameraLight]) -> TourCamera:
	for i in mcl_list.size():
		enqueue(mcl_list[i].get_camera(), mcl_list[(i+1)%mcl_list.size()].get_camera() )
	return self

func init_by_camera3d_list(mcl_list :Array[Camera3D]) -> TourCamera:
	for i in mcl_list.size():
		enqueue(mcl_list[i], mcl_list[(i+1)%mcl_list.size()] )
	return self

func start() -> void:
	make_current()
	next()

func stop() -> void:
	tour_animation.force_end(false)

func make_current() -> void:
	$Camera3D.current = true

func enqueue(from :Camera3D, to :Camera3D) -> void:
	animation_queue.append([
		{
		"Name" : "move",
		"AniNode" : self,
		"Field" : "global_position",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur,
		},
		{
		"Name" : "rotation",
		"AniNode" : self,
		"Field" : "global_rotation",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur,
		},
		{
		"Name" : "fov",
		"AniNode" : $Camera3D,
		"Field" : "fov",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur,
		},
		{
		"Name" : "far",
		"AniNode" : $Camera3D,
		"Field" : "far",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur,
		},
	])
	# keep following
	animation_queue.append([
		{
		"Name" : "move",
		"AniNode" : self,
		"Field" : "global_position",
		"From" : to,
		"To" : to,
		"DurSec" : wait_btw_animation,
		},
		{
		"Name" : "rotation",
		"AniNode" : self,
		"Field" : "global_rotation",
		"From" : to,
		"To" : to,
		"DurSec" : wait_btw_animation,
		},
	])

func animation_ended(_st :Node, _ani :Dictionary) -> void:
	if tour_animation.is_empty():
		next()

func next() -> void:
	var ani_list = animation_queue.pop_front()
	for ani in ani_list:
		tour_animation.add_animation(ani)
	animation_queue.append(ani_list)

func _process(_delta: float) -> void:
	tour_animation.handle_animation()
