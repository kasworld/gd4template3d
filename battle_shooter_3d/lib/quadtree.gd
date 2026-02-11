class_name QuadTree

var boundary: Rect2
var children :Array[QuadTree] # [0]-[3]: NW, NE, SW, SE
var points :Dictionary[Vector2, Variant]
var max_depth :int
var capacity :int
var depth :int

func _init(boundary_a :Rect2, capacity_a :int, max_depth_a :int = 0, depth_a :int = 0):
	boundary = boundary_a
	max_depth = max_depth_a
	depth = depth_a
	capacity = capacity_a
	children = []
	points = {}

func insert(position :Vector2, value :Node = null) -> bool:
	if !contains(position):
		return false
	if children.is_empty() and !is_at_capacity():
		points[position] = value
		return true
	subdivide()
	for child in children:
		if child.insert(position, value):
			return true
	return false

func search_region(region: Rect2, return_values=false, matches=null)->Array:
	if matches == null:
		matches = []
	if !overlaps(region):
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

func search(position: Vector2, width: float, height: float, return_values=false, matches=null) -> Array:
	var region := Rect2(position - Vector2(width/2, height/2), Vector2(width, height))
	var p_list := search_region(region, return_values, matches)
	var rtn :Array[Node] = []
	for p in p_list:
		rtn.append(points[p])
	return rtn

func overlaps(region: Rect2) -> bool:
	return region.intersects(boundary, true)

func contains(position: Vector2) -> bool:
	return boundary.has_point(position)

func is_at_capacity() -> bool:
	return points.size() >= capacity

func subdivide():
	if children.is_empty() and (max_depth <= 0 or depth < max_depth):
		children = [
			QuadTree.new(Rect2(boundary.position, boundary.size/2),
				capacity, max_depth, depth + 1),
			QuadTree.new(Rect2(boundary.position.x + boundary.size.x/2, boundary.position.y, boundary.size.x/2, boundary.size.y/2),
				capacity, max_depth, depth + 1),
			QuadTree.new(Rect2(boundary.position.x, boundary.position.y + boundary.size.y/2, boundary.size.x/2, boundary.size.y/2),
				capacity, max_depth, depth + 1),
			QuadTree.new(Rect2(boundary.position.x + boundary.size.x/2, boundary.position.y + boundary.size.y/2, boundary.size.x/2, boundary.size.y/2),
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
