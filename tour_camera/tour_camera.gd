extends Node3D
class_name TourCamera

var wait_btw_animation := 1.0
var animation_dur := 1.0

var animation_queue :Array # [ [ move, rotate, fov ] ]
var tour_animation :SimpleAnimation

func init(gc_list :Array[GlassCabinet]) -> TourCamera:
	animation_queue = []
	tour_animation = SimpleAnimation.new()
	tour_animation.animation_ended.connect(animation_ended)
	for i in gc_list.size():
		enqueue(gc_list[i], gc_list[(i+1)%gc_list.size()])
	return self

func start() -> void:
	make_current()
	next()

func stop() -> void:
	tour_animation.force_end(false)

func make_current() -> void:
	$Camera3D.current = true

func enqueue(from :GlassCabinet, to :GlassCabinet) -> void:
	animation_queue.append([
		{
		"Name" : "move",
		"AniNode" : self,
		"Field" : "global_position",
		"From" : from.get_camera_light(),
		"To" : to.get_camera_light(),
		"DurSec" : animation_dur,
		},
		{
		"Name" : "rotation",
		"AniNode" : self,
		"Field" : "global_rotation",
		"From" : from.get_camera_light(),
		"To" : to.get_camera_light(),
		"DurSec" : animation_dur,
		},
		{
		"Name" : "fov",
		"AniNode" : $Camera3D,
		"Field" : "fov",
		"From" : from.get_camera_light().get_camera(),
		"To" : to.get_camera_light().get_camera(),
		"DurSec" : animation_dur,
		},
		{
		"Name" : "far",
		"AniNode" : $Camera3D,
		"Field" : "far",
		"From" : from.get_camera_light().get_camera(),
		"To" : to.get_camera_light().get_camera(),
		"DurSec" : animation_dur,
		},
	])
	# keep following
	animation_queue.append([
		{
		"Name" : "move",
		"AniNode" : self,
		"Field" : "global_position",
		"From" : to.get_camera_light(),
		"To" : to.get_camera_light(),
		"DurSec" : wait_btw_animation,
		},
		{
		"Name" : "rotation",
		"AniNode" : self,
		"Field" : "global_rotation",
		"From" : to.get_camera_light(),
		"To" : to.get_camera_light(),
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
