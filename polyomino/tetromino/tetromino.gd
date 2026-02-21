extends Node3D
class_name Tetromino

enum Type {I,T,J,L,S,Z,O}

func type_to_string(t :Type) -> String:
	return Type.keys()[t]

static func rand_type() -> Type:
	return randi_range(0, Type.size() )

const Geo := {
	# type, geo rotation
	Type.O: [[[0,0],[1,0],[1,1],[0,1]], ],
	Type.I: [[[-1,2],[0,2],[1,2],[2,2]], [[1,0],[1,1],[1,2],[1,3]], ],
	Type.S: [[[2,1],[1,1],[1,2],[0,2]], [[1,0],[1,1],[2,1],[2,2]], ],
	Type.Z: [[[0,1],[1,1],[1,2],[2,2]], [[2,0],[2,1],[1,1],[1,2]], ],
	Type.T: [[[0,1],[1,1],[2,1],[1,2]], [[1,0],[1,1],[1,2],[0,1]], [[0,1],[1,1],[2,1],[1,0]],  [[1,0],[1,1],[1,2],[2,1]], ],
	Type.J: [[[0,1],[1,1],[2,1],[2,2]], [[1,0],[1,1],[1,2],[0,2]], [[0,1],[1,1],[2,1],[0,0]],  [[1,0],[1,1],[1,2],[2,0]], ],
	Type.L: [[[0,1],[1,1],[2,1],[0,2]], [[1,0],[1,1],[1,2],[0,0]], [[0,1],[1,1],[2,1],[2,0]],  [[1,0],[1,1],[1,2],[2,2]], ],
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

func init(t :Type, l :float) -> Tetromino:
	for p in Geo[t][0]:
		var mm :Monomino = preload("res://polyomino/monomino/monomino.tscn").instantiate(
			).init(l*0.95 , Color(TypeToColor[t],0.5))
		mm.position = Vector3(p[0]*l,p[1]*l,0)
		add_child(mm)
	return self
