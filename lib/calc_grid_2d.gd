class_name CalcGrid2D

var boundary :Rect2
var grid_size :Vector2i
var unit_size :Vector2

func init(b_rect :Rect2, g_size :Vector2i) -> CalcGrid2D:
	boundary = b_rect
	grid_size = g_size
	unit_size = boundary.size / (grid_size as Vector2)
	return self

func posi_to_pos(posi :Vector2i) -> Vector2:
	return boundary.position + (posi as Vector2)* unit_size
