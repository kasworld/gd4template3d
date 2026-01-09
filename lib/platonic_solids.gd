class_name PlatonicSolids

const GoldenRatio :float = (1+sqrt(5))/2

## key : face count , value : point list
static var Points = {
	4 : TetrahedronPoints,
	6 : CubePoints,
	8 : OctahedronPoints,
	12 : DodecahedronPoints,
	20 : IcosahedronPoints,
}

## key : face count , value : edge count per vertex
static var EdgePerVertex = {
	4 : 3,
	6 : 3,
	8 : 4,
	12 : 3,
	20 : 5,
}

## face 4
const TetrahedronPoints := [
	Vector3(1,1,1),
	Vector3(1,-1,-1),
	Vector3(-1,1,-1),
	Vector3(-1,-1,1),
]

## face 6
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

## face 8
const OctahedronPoints := [
	Vector3(1,0,0),
	Vector3(0,1,0),
	Vector3(0,0,1),
	Vector3(-1,0,0),
	Vector3(0,-1,0),
	Vector3(0,0,-1),
]

## face 12
const DodecahedronPoints := [
	Vector3(1,1,1),
	Vector3(-1,1,1),
	Vector3(1,-1,1),
	Vector3(-1,-1,1),
	Vector3(1,1,-1),
	Vector3(-1,1,-1),
	Vector3(1,-1,-1),
	Vector3(-1,-1,-1),
	Vector3(0, 1/GoldenRatio, GoldenRatio),
	Vector3(0, -1/GoldenRatio, GoldenRatio),
	Vector3(0, 1/GoldenRatio, -GoldenRatio),
	Vector3(0, -1/GoldenRatio, -GoldenRatio),
	Vector3(1/GoldenRatio, GoldenRatio, 0),
	Vector3(-1/GoldenRatio, GoldenRatio, 0),
	Vector3(1/GoldenRatio, -GoldenRatio, 0),
	Vector3(-1/GoldenRatio, -GoldenRatio, 0),
	Vector3(GoldenRatio, 0, 1/GoldenRatio),
	Vector3(GoldenRatio, 0, -1/GoldenRatio),
	Vector3(-GoldenRatio, 0, 1/GoldenRatio),
	Vector3(-GoldenRatio, 0, -1/GoldenRatio),
]

## face 20
const IcosahedronPoints :Array = [
	Vector3(0,1,GoldenRatio),
	Vector3(0,-1,GoldenRatio),
	Vector3(0,1,-GoldenRatio),
	Vector3(0,-1,-GoldenRatio),
	Vector3(1,GoldenRatio,0),
	Vector3(-1,GoldenRatio,0),
	Vector3(1,-GoldenRatio,0),
	Vector3(-1,-GoldenRatio,0),
	Vector3(GoldenRatio,0,1),
	Vector3(GoldenRatio,0,-1),
	Vector3(-GoldenRatio,0,1),
	Vector3(-GoldenRatio,0,-1),
]

## face 4
static var TetrahedronPointsNomalized := NormalizePointList(TetrahedronPoints)
static var TetrahedronLines := PointListToLineList(TetrahedronPoints,3)
static var TetrahedronLinesNomalized := PointListToLineList(TetrahedronPointsNomalized,3)
## face 6
static var CubePointsNomalized := NormalizePointList(CubePoints)
static var CubeLines := PointListToLineList(CubePoints,3)
static var CubeLinesNomalized := PointListToLineList(CubePointsNomalized,3)
## face 8
static var OctahedronPointsNomalized := NormalizePointList(OctahedronPoints)
static var OctahedronLines := PointListToLineList(OctahedronPoints,4)
static var OctahedronLinesNomalized := PointListToLineList(OctahedronPointsNomalized,4)
## face 12
static var DodecahedronPointsNomalized := NormalizePointList(DodecahedronPoints)
static var DodecahedronLines := PointListToLineList(DodecahedronPoints,3)
static var DodecahedronLinesNomalized := PointListToLineList(DodecahedronPointsNomalized,3)
## face 20
static var IcosahedronPointsNomalized := NormalizePointList(IcosahedronPoints)
static var IcosahedronLines := PointListToLineList(IcosahedronPoints,5)
static var IcosahedronLinesNomalized := PointListToLineList(IcosahedronPointsNomalized,5)


static func MultiplyLineList(line_list :Array,  m :float) -> Array:
	var rtn := []
	for l in line_list:
		var ml := []
		for v in l:
			ml.append(v*m)
		rtn.append(ml)
	return rtn

static func NormalizePointList(point_list :Array) -> Array:
	var rtn := []
	for l :Vector3 in point_list:
		l.normalized()
		rtn.append(l.normalized())
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
