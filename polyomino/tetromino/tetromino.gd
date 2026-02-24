extends Node3D
class_name Tetromino

enum Type {I,T,J,L,S,Z,O}

func type_to_string(t :Type) -> String:
	return Type.keys()[t]

static func rand_type() -> Type:
	return randi_range(0, Type.size() ) as Type

const Geo := {
	# type, geo rotation
	Type.O: [
		[[0,0],[1,0],[1,1],[0,1]],
		[[0,1],[0,0],[1,0],[1,1]],
		[[1,1],[0,1],[0,0],[1,0]],
		[[1,0],[1,1],[0,1],[0,0]],
		],
	Type.I: [
		[[2,0],[1,0],[0,0],[-1,0]],
		[[1,-1],[1,0],[1,1],[1,2]],
		[[-1,1],[0,1],[1,1],[2,1]],
		[[0,2],[0,1],[0,0],[0,-1]],
		],
	Type.S: [
		#[[2,1],[1,1],[1,2],[0,2]],
		#[[1,0],[1,1],[2,1],[2,2]],
		[[1,1],[2,1],[1,2],[0,2]],
		[[1,1],[2,1],[1,0],[2,2]],
		],
	Type.Z: [
		#[[0,1],[1,1],[1,2],[2,2]],
		#[[2,0],[2,1],[1,1],[1,2]],
		[[1,1],[1,2],[0,1],[2,2]],
		[[1,1],[1,2],[2,1],[2,0]],
		],
	Type.T: [ # [1,1], [0,1],[1,2],[2,1],[1,0]
		[[1,1], [0,1],[1,2],[2,1]],
		[[1,1], [1,2],[2,1],[1,0]],
		[[1,1], [2,1],[1,0],[0,1]],
		[[1,1], [1,0],[0,1],[1,2]],
		],
	Type.J: [
		[[1,1], [0,1],[2,1],[2,2]],
		[[1,1], [1,2],[1,0],[2,0]],
		[[1,1], [2,1],[0,1],[0,0]],
		[[1,1], [1,0],[1,2],[0,2]],
		],
	Type.L: [
		[[1,1], [0,1],[2,1],[0,2]],
		[[1,1], [1,2],[1,0],[2,2]],
		[[1,1], [2,1],[0,1],[2,0]],
		[[1,1], [1,0],[1,2],[0,0]],
		],
}

const TypeToColor = {
	Type.O: Color.AQUA,
	Type.I: Color.BLUE,
	Type.S: Color.RED,
	Type.Z: Color.YELLOW,
	Type.T: Color.GREEN,
	Type.J: Color.MAGENTA,
	Type.L: Color.ORANGE,
}

var animation := SimpleAnimation.new()

var monomino_list :Array = []
var monomino_len :float
var tetromino_type :Type
var tetromino_rot :int

func calc_geo_to_vt3(p :Array) -> Vector3:
	return Vector3(p[0]*monomino_len,p[1]*monomino_len,0) #+ Vector3(-monomino_len,monomino_len,0)
func make_type_color(t :Type) -> Color:
	return Color(TypeToColor[t],0.5)
func get_geo(t :Type, rot :int) -> Array:
	return Geo[t][rot%Geo[t].size()]

func init(t :Type, rot :int,  l :float) -> Tetromino:
	monomino_len = l
	tetromino_type = t
	tetromino_rot = rot
	for p in get_geo(tetromino_type, tetromino_type):
		var mm :Monomino = preload("res://polyomino/monomino/monomino.tscn").instantiate(
			).init(l*0.95 , make_type_color(t))
		mm.position = calc_geo_to_vt3(p)
		add_child(mm)
		monomino_list.append(mm)
	return self

const AniSec := 0.5
func animate_to(t :Type, rot :int) -> void:
	if not animation.is_empty():
		animation.force_end(false)
	var old_color := make_type_color(tetromino_type)
	tetromino_type = t
	tetromino_rot = rot
	var new_geo := get_geo(tetromino_type, tetromino_rot)
	for i in monomino_list.size():
		animation.start_move("", monomino_list[i], monomino_list[i].position, calc_geo_to_vt3(new_geo[i]), AniSec)
		animation.add_animation({
			"Name" : name, # for end signal
			"AniNode" : monomino_list[i],
			"Field" : "color",
			"From" : old_color,
			"To" : make_type_color(tetromino_type),
			"DurSec" : AniSec,
		})

func _process(_delta: float) -> void:
	animation.handle_animation()
