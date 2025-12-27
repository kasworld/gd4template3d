class_name AnimateGradient

static func random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]

var color_list := [random_color(),random_color(),random_color(),random_color()]
var color_rate :float

func inc_rate(v :float = 1.0/60.0) -> void:
	color_rate += v
	if color_rate >= 1:
		color_rate = 0
		color_list = [color_list[1], random_color(), color_list[3], random_color()]

func get_color1() -> Color:
		return lerp(color_list[0], color_list[1],color_rate)

func get_color2() -> Color:
		return lerp(color_list[2], color_list[3],color_rate)
