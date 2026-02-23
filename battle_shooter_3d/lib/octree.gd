class_name Octree

var boundary: AABB
var children :Array[Octree] # [0]-[3]: NW, NE, SW, SE
var pos_to_obj :Dictionary[Vector3, Variant]
var max_depth :int
var capacity :int
var depth :int

func overlaps(region: AABB) -> bool:
	return region.intersects(boundary)

func contains(position: Vector3) -> bool:
	return boundary.has_point(position)

func is_at_capacity() -> bool:
	return pos_to_obj.size() >= capacity

func _init(boundary_a :AABB, capacity_a :int, max_depth_a :int = 0, depth_a :int = 0) -> void:
	boundary = boundary_a
	max_depth = max_depth_a
	depth = depth_a
	capacity = capacity_a
	children = []
	pos_to_obj = {}

func insert(position :Vector3, value :BSObj = null) -> bool:
	if not contains(position):
		return false
	if children.is_empty() and not is_at_capacity():
		pos_to_obj[position] = value
		return true
	subdivide()
	for child in children:
		if child.insert(position, value):
			return true
	return false

func search_region(region: AABB, matches :Array[BSObj]= []) -> Array[BSObj]:
	if not overlaps(region):
		return matches
	for point in pos_to_obj.keys():
		if region.has_point(point):
			matches.append(pos_to_obj[point])
	for child in children:
		child.search_region(region, matches)
	return matches

func search(start_position: Vector3, search_size: Vector3, matches:Array[BSObj]=[]) -> Array[BSObj]:
	var region := AABB(start_position - search_size/2 , search_size)
	return search_region(region, matches)

func subdivide() -> bool:
	if children.is_empty() and (max_depth <= 0 or depth < max_depth):
		children = [
			Octree.new(AABB(boundary.position + Vector3(0                , boundary.size.y/2, boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(0                , 0                , boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(0                , boundary.size.y/2, 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(0                , 0                , 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(boundary.size.x/2, boundary.size.y/2, boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(boundary.size.x/2, 0                , boundary.size.z/2), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(boundary.size.x/2, boundary.size.y/2, 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
			Octree.new(AABB(boundary.position + Vector3(boundary.size.x/2, 0                , 0                ), boundary.size/2),
				capacity, max_depth, depth + 1),
		]
		var point_positions := pos_to_obj.keys()
		for i in range(point_positions.size()):
			var point :Vector3 = point_positions.pop_back()
			var value = pos_to_obj[point]
			pos_to_obj.erase(point)
			for child in children:
				if child.contains(point):
					child.pos_to_obj[point] = value
		return true
	return false
