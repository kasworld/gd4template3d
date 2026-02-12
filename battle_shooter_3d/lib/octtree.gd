class_name OctTree

var boundary: AABB
var children :Array[OctTree] # [0]-[3]: NW, NE, SW, SE
var points :Dictionary[Vector3, Variant]
var max_depth :int
var capacity :int
var depth :int

func _init(boundary_a :AABB, capacity_a :int, max_depth_a :int = 0, depth_a :int = 0) -> void:
	boundary = boundary_a
	max_depth = max_depth_a
	depth = depth_a
	capacity = capacity_a
	children = []
	points = {}

func insert(position :Vector3, value :Node = null) -> bool:
	if not contains(position):
		return false
	if children.is_empty() and not is_at_capacity():
		points[position] = value
		return true
	subdivide()
	for child in children:
		if child.insert(position, value):
			return true
	return false

func search_region(region: AABB, return_values=false, matches=null) -> Array:
	if matches == null:
		matches = []
	if not overlaps(region):
		return matches
	for point in points.keys():
		if region.has_point(point):
			if return_values: # are we returning the positions or the objects at those positions?
				matches.append(points[point])
			else:
				matches.append(point)
	for child in children:
		child.search_region(region, return_values, matches)
	return matches

func search(position: Vector3, size: Vector3, return_values=false, matches=null) -> Array:
	var region := AABB(position - size/2 , size)
	var p_list := search_region(region, return_values, matches)
	var rtn :Array[Node] = []
	for p in p_list:
		rtn.append(points[p])
	return rtn

func overlaps(region: AABB) -> bool:
	return region.intersects(boundary)

func contains(position: Vector3) -> bool:
	return boundary.has_point(position)

func is_at_capacity() -> bool:
	return points.size() >= capacity

func subdivide() -> bool:
	if children.is_empty() and (max_depth <= 0 or depth < max_depth):
		children = [
			OctTree.new(AABB(boundary.position + Vector3(0                , boundary.size.y/2, boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(0                , 0                , boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(0                , boundary.size.y/2, 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(0                , 0                , 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(boundary.size.x/2, boundary.size.y/2, boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(boundary.size.x/2, 0                , boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(boundary.size.x/2, boundary.size.y/2, 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			OctTree.new(AABB(boundary.position + Vector3(boundary.size.x/2, 0                , 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
		]
		var point_positions := points.keys()
		for i in range(point_positions.size()):
			var point :Vector3 = point_positions.pop_back()
			var value = points[point]
			points.erase(point)
			for child in children:
				if child.contains(point):
					child.points[point] = value
		return true
	return false
