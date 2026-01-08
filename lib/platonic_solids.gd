class_name PlatonicSolids

const CubePoints := [
	Vector3(1,1,1),
	Vector3(-1,1,1),
	Vector3(1,-1,1),
	Vector3(-1,-1,1),
	Vector3(1,1,-1),
	Vector3(-1,1,-1),
	Vector3(1,-1,-1),
	Vector3(-1,-1,-1),
]
static var CubeLines := PointListToLineList(CubePoints,3)

const TetrahedronPoints := [
	Vector3(1,1,1),
	Vector3(1,-1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,-1,1),
]
static var TetrahedronLines := PointListToLineList(TetrahedronPoints,3)

const OctahedronPoints := [
	Vector3(1,0,0),
	Vector3(0,1,0),
	Vector3(0,0,1),
	Vector3(-1,0,0),
	Vector3(0,-1,0),
	Vector3(0,0,-1),
]
static var OctahedronLines := PointListToLineList(OctahedronPoints,4)

static var golden_ratio := (1+sqrt(5))/2
static var IcosahedronPoints :Array= [
	Vector3(0,1,golden_ratio),
	Vector3(0,-1,golden_ratio),
	Vector3(0,1,-golden_ratio),
	Vector3(0,-1,-golden_ratio),
	Vector3(1,golden_ratio,0),
	Vector3(-1,golden_ratio,0),
	Vector3(1,-golden_ratio,0),
	Vector3(-1,-golden_ratio,0),
	Vector3(golden_ratio,0,1),
	Vector3(golden_ratio,0,-1),
	Vector3(-golden_ratio,0,1),
	Vector3(-golden_ratio,0,-1),
]
static var IcosahedronLines := PointListToLineList(IcosahedronPoints,5)

static var DodecahedronPoints := [
	Vector3(1,1,1),
	Vector3(-1,1,1),
	Vector3(1,-1,1),
	Vector3(-1,-1,1),
	Vector3(1,1,-1),
	Vector3(-1,1,-1),
	Vector3(1,-1,-1),
	Vector3(-1,-1,-1),
	Vector3(0, 1/golden_ratio, golden_ratio),
	Vector3(0, -1/golden_ratio, golden_ratio),
	Vector3(0, 1/golden_ratio, -golden_ratio),
	Vector3(0, -1/golden_ratio, -golden_ratio),
	Vector3(1/golden_ratio, golden_ratio, 0),
	Vector3(-1/golden_ratio, golden_ratio, 0),
	Vector3(1/golden_ratio, -golden_ratio, 0),
	Vector3(-1/golden_ratio, -golden_ratio, 0),
	Vector3(golden_ratio, 0, 1/golden_ratio),
	Vector3(golden_ratio, 0, -1/golden_ratio),
	Vector3(-golden_ratio, 0, 1/golden_ratio),
	Vector3(-golden_ratio, 0, -1/golden_ratio),
]
static var DodecahedronLines := PointListToLineList(DodecahedronPoints,3)

static func MultiplyLineList(line_list :Array,  m :float) -> Array:
	var rtn := []
	for l in line_list:
		var ml := []
		for v in l:
			ml.append(v*m)
		rtn.append(ml)
	return rtn

## m can float, Vector3
static func MultiplyPointList(point_list :Array, m ) -> Array:
	var rtn := []
	for l in point_list:
		rtn.append(l*m)
	return rtn

## cut_count : edge count per vertex
static func PointListToLineList(point_list:Array, cut_count :int) -> Array:
	var sorted_point_list_list := []
	# 각 배열의 첫 원소와 가장 가까운 순으로 점들을 정렬한다.
	for p :Vector3 in point_list:
		var plist := point_list.duplicate()
		plist.sort_custom(func(a , b): return p.distance_to(a) < p.distance_to(b))
		sorted_point_list_list.append(plist)
	# make_line_from_sorted_point_list_list
	var line_list := []
	for v in sorted_point_list_list:
		for i in cut_count:
			# prepare del duplicated line
			if v[0] < v[1+i]:
				line_list.append([v[0], v[1+i]])
			else:
				line_list.append([v[1+i], v[0]])
	line_list.sort_custom(func(a,b): return a < b)
	var rtn := []
	# del duplicated line
	for i in range(0,line_list.size(),2):
		rtn.append(line_list[i])
	return rtn
