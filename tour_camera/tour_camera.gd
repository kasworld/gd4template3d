extends Node3D
class_name TourCamera

var wait_btw_animation := 1.0
var animation_dur := 1.0

var animation_queue :Array # [ [ move, rotate, fov ] ]
var tour_animation :SimpleAnimation

func init() -> TourCamera:
	animation_queue = []
	tour_animation = SimpleAnimation.new()
	tour_animation.animation_ended.connect(animation_ended)
	return self

func make_current() -> void:
	$Camera3D.current = true

func enqueue(from :Node, to :Node) -> void:
	var ani_list := [
		{
		"Name" : "move",
		"AniNode" : $Camera3D,
		"Field" : "global_position",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur,
		},
		{
		"Name" : "rotation",
		"AniNode" : $Camera3D,
		"Field" : "global_rotation",
		"From" : from,
		"To" : to,
		"DurSec" : animation_dur,
		},
		#{
		#"Name" : "fov",
		#"AniNode" : $Camera3D,
		#"Field" : "fov",
		#"From" : from,
		#"To" : to,
		#"DurSec" : animation_dur,
		#},
		#{
		#"Name" : "far",
		#"AniNode" : $Camera3D,
		#"Field" : "far",
		#"From" : from,
		#"To" : to,
		#"DurSec" : animation_dur,
		#},
	]
	animation_queue.append(ani_list)

func animation_ended(_st :Node, _ani :Dictionary) -> void:
	if tour_animation.is_empty():
		$TimerWait.start(wait_btw_animation)

func _on_timer_wait_timeout() -> void:
	start()

func start() -> void:
	var ani_list = animation_queue.pop_front()
	#print_debug(ani_list)
	for ani in ani_list:
		tour_animation.add_animation(ani)
	animation_queue.append(ani_list)

func _process(_delta: float) -> void:
	tour_animation.handle_animation()
