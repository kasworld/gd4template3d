extends SBObj
class_name SBApple

var field :PlacedThings
var number :int
var pos2d :Vector2i
var rotate_v :float

func _to_string() -> String:
	return "SBApple%d (%d,%d)" % [number, pos2d.x,pos2d.y]

func init(f :PlacedThings, n :int) -> SBApple:
	number = n
	$"번호".text = "%d" % number
	field = f
	$"모양".mesh.material.albedo_color = NamedColors.random_color()
	$"모양".mesh.inner_radius = SnakeByte.tile_size.x /6
	$"모양".mesh.outer_radius = SnakeByte.tile_size.x /2
	$"모양".rotation.z = randf_range(-PI,PI)
	rotate_v = randf_range(-5,5)

	var pos := field.find_empty_pos(10)
	pos2d = pos
	assert(pos!=Vector2i(-1,-1), "fail to find empty pos in field")
	var old = field.set_at(pos, self)
	assert(old == null, "%s pos not empty %s" % [self, old])
	position = get_pos3d()
	return self

func get_pos2d() -> Vector2i:
	return pos2d

func get_pos3d() -> Vector3:
	return SnakeByte.calc_grid.posi_to_lanepos( CalcGrid3D.Vector2iToVector3i(pos2d,0))

func delete() -> void:
	var old = field.del_at(pos2d)
	assert( old is SBApple, "not %s at %s %s" % [self, pos2d , old] )

func _process(delta: float) -> void:
	$"모양".rotate_x(delta*rotate_v)
