extends Node3D
class_name TourCamera

var animation_queue :Array
var tour_animation :SimpleAnimation

func init() -> TourCamera:
	animation_queue = []
	tour_animation = SimpleAnimation.new()
	tour_animation.animation_ended.connect(animation_ended)
	return self

func animation_ended(_st :Node, _ani :Dictionary) -> void:
	$TimerWait.start(1.0)

func _on_timer_wait_timeout() -> void:
	var ani = animation_queue.pop_front()
	tour_animation.a
