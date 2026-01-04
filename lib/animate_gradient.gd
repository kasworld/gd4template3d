class_name AnimateGradient

static func random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]

var random_fn :Callable

func _init(random_fn_a :Callable = random_color) -> void:
	set_random_fn(random_fn_a)
	color_list = [random_fn.call(),random_fn.call(),random_fn.call(),random_fn.call()]

func set_random_fn(random_fn_a :Callable) -> AnimateGradient:
	random_fn = random_fn_a
	return self

var color_list :Array
var color_rate :float

func inc_rate(v :float = 1.0/60.0) -> void:
	color_rate += v
	if color_rate >= 1:
		color_rate = 0
		color_list = [color_list[1], random_fn.call(), color_list[3], random_fn.call()]

func get_color1() -> Color:
		return lerp(color_list[0], color_list[1],color_rate)

func get_color2() -> Color:
		return lerp(color_list[2], color_list[3],color_rate)
