class_name CalcGrid3D

var boundary :AABB
var grid_size :Vector3i
var unit_size :Vector3

static func Vector2iToVector3i(vt2i :Vector2i, z :int) -> Vector3i:
	return Vector3i(vt2i.x, vt2i.y, z)

static func Vector3iToVector2i(vt3i :Vector3i) -> Vector2i:
	return Vector2i(vt3i.x, vt3i.y)

static func SizeToAABB(size :Vector3) -> AABB:
	return AABB(-size/2, size)

func _init(b_rect :AABB, g_size :Vector3i) -> void:
	boundary = b_rect
	grid_size = g_size
	unit_size = boundary.size / (grid_size as Vector3)

func posi_to_linepos(posi :Vector3i) -> Vector3:
	return boundary.position + (posi as Vector3)* unit_size

func linepos_to_posi(pos :Vector3) -> Vector3i:
	return  ((pos - boundary.position) / unit_size).snappedf(1.0) as Vector3i

func posi_to_lanepos(posi :Vector3i) -> Vector3:
	return boundary.position + (posi as Vector3)* unit_size + unit_size/2

func lanepos_to_posi(pos :Vector3) -> Vector3i:
	return  ((pos - boundary.position - unit_size/2) / unit_size).snappedf(1.0) as Vector3i
	#return Vector3i(
		#snappedi( (pos.x + boundary.size.x/2 - unit_size.x/2) / unit_size.x , 1 ),
		#snappedi( (pos.y + boundary.size.y/2 - unit_size.y/2) / unit_size.y , 1 ),
		#snappedi( (pos.z + boundary.size.z/2 - unit_size.z/2) / unit_size.z , 1 ),
	#)
