class_name CalcGrid3D

var boundary :AABB
var grid_size :Vector3i
var unit_size :Vector3

func _init(b_rect :AABB, g_size :Vector3i) -> void:
	boundary = b_rect
	grid_size = g_size
	unit_size = boundary.size / (grid_size as Vector3)

func posi_to_linepos(posi :Vector3i) -> Vector3:
	return boundary.position + (posi as Vector3)* unit_size

func posi_to_lanepos(posi :Vector3i) -> Vector3:
	return boundary.position + (posi as Vector3)* unit_size + unit_size/2
