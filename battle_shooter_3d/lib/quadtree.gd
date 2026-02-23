class_name QuadTree

var boundary: Rect2
var children :Array[QuadTree] # [0]-[3]: NW, NE, SW, SE
var points :Dictionary[Vector2, Variant]
var max_depth :int
var capacity :int
var depth :int

func overlaps(region: Rect2) -> bool:
	return region.intersects(boundary, true)

func contains(position: Vector2) -> bool:
	return boundary.has_point(position)

func is_at_capacity() -> bool:
	return points.size() >= capacity

func _init(boundary_a :Rect2, capacity_a :int, max_depth_a :int = 0, depth_a :int = 0) -> void:
	boundary = boundary_a
	max_depth = max_depth_a
	depth = depth_a
	capacity = capacity_a
	children = []
	points = {}

func insert(position :Vector2, value :Node = null) -> bool:
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

func search_region(region: Rect2, matches=null) -> Array:
	if matches == null:
		matches = []
	if not overlaps(region):
		return matches
	for point in points.keys():
		if region.has_point(point):
			matches.append(points[point])
	for child in children:
		child.search_region(region, matches)
	return matches

func search(position: Vector2, width: float, height: float, matches=null) -> Array:
	var region := Rect2(position - Vector2(width/2, height/2), Vector2(width, height))
	return search_region(region, matches)

func subdivide() -> bool:
	if children.is_empty() and (max_depth <= 0 or depth < max_depth):
		children = [
			QuadTree.new(Rect2(boundary.position + Vector2(0,                 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			QuadTree.new(Rect2(boundary.position + Vector2(boundary.size.x/2, 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			QuadTree.new(Rect2(boundary.position + Vector2(0,                 boundary.size.y/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			QuadTree.new(Rect2(boundary.position + Vector2(boundary.size.x/2, boundary.size.y/2), boundary.size/2),
				capacity, max_depth, depth + 1),
		]
		var point_positions := points.keys()
		for i in range(point_positions.size()):
			var point :Vector2 = point_positions.pop_back()
			var value = points[point]
			points.erase(point)
			for child in children:
				if child.contains(point):
					child.points[point] = value
		return true
	return false
