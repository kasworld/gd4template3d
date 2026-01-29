extends Node3D
class_name TourCamera

var wait_btw_animation := 1.0
var animation_dur_sec := 1.0

var animation_route :ListIter
var tour_animation :SimpleAnimation
var animation_queue :Array
func _init() -> void:
	animation_queue = []
	tour_animation = SimpleAnimation.new()
	tour_animation.animation_ended.connect(animation_ended)

func init_by_glass_cabinet_list(gc_list :Array[GlassCabinet]) -> TourCamera:
	var route_list :Array = []
	for i in gc_list.size():
		route_list.append( [
			get_camera_from_glass_cabinet(gc_list[i]),
			get_camera_from_glass_cabinet(gc_list[(i+1)%gc_list.size()])
			])
	animation_route = ListIter.new(route_list,false)
	return self
func get_camera_from_glass_cabinet(gc :GlassCabinet) -> Camera3D:
	return gc.get_camera_light().get_camera()

func init_by_moving_camera_light_list(mcl_list :Array[MovingCameraLight]) -> TourCamera:
	var route_list :Array = []
	for i in mcl_list.size():
		route_list.append( [
		mcl_list[i].get_camera(), mcl_list[(i+1)%mcl_list.size()].get_camera()
			])
	animation_route = ListIter.new(route_list,false)
	return self

func init_by_camera3d_list(mcl_list :Array[Camera3D]) -> TourCamera:
	var route_list :Array = []
	for i in mcl_list.size():
		route_list.append([
		mcl_list[i], mcl_list[(i+1)%mcl_list.size()]
			])
	animation_route = ListIter.new(route_list,false)
	return self

func start() -> void:
	make_current()
	next()

func stop() -> void:
	tour_animation.force_end(false)

func make_current() -> void:
	$Camera3D.current = true

func route_to_ani_list(from :Camera3D, to :Camera3D) -> Array:
	return [
		[{
		"Name" : "move",
		"AniNode" : self,
		"Field" : "global_position",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur_sec,
		},{
		"Name" : "rotation",
		"AniNode" : self,
		"Field" : "global_rotation",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur_sec,
		},{
		"Name" : "fov",
		"AniNode" : $Camera3D,
		"Field" : "fov",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur_sec,
		},{
		"Name" : "far",
		"AniNode" : $Camera3D,
		"Field" : "far",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur_sec,
		}],
		# keep following
		[{
		"Name" : "move",
		"AniNode" : self,
		"Field" : "global_position",
		"From" : to,
		"To" : to,
		"DurSec" : wait_btw_animation,
		},{
		"Name" : "rotation",
		"AniNode" : self,
		"Field" : "global_rotation",
		"From" : to,
		"To" : to,
		"DurSec" : wait_btw_animation,
		}]
	]

func animation_ended(_st :Node, _ani :Dictionary) -> void:
	if tour_animation.is_empty():
		next()

func queue_to_animation() -> void:
	if animation_queue.is_empty():
		return
	var ani_list = animation_queue.pop_front()
	for ani in ani_list:
		tour_animation.add_animation(ani)

func next() -> void:
	if animation_queue.is_empty():
		var route = animation_route.get_current()
		animation_route.next()
		var ani_list_list := route_to_ani_list(route[0],route[1])
		for ani_list in ani_list_list:
			animation_queue.append(ani_list)
	queue_to_animation()

func _process(_delta: float) -> void:
	tour_animation.handle_animation()
