extends Node3D
class_name Monomino

var color :Color :
	set(co):
		set_color(co,co)


func init(l :float, co :Color) -> Monomino:
	set_color(co, co)
	set_size(l, l*0.75)
	return self

func set_size(outer_l :float, inner_l :float) -> Monomino:
	$InnerCube.mesh.size = Vector3(inner_l,inner_l,inner_l)
	$OuterCube.mesh.size = Vector3(outer_l,outer_l,outer_l)
	return self

func set_color(outer_co :Color, inner_co :Color) -> Monomino:
	$OuterCube.mesh.material.albedo_color = outer_co
	$InnerCube.mesh.material.albedo_color = inner_co
	return self

func make_rotate_animation(dir :Vector3, ani_sec :float, ani_name:String="") -> Dictionary:
	match dir:
		Vector3.DOWN:
			return SimpleAnimation.MakeRotationSubfield(ani_name, self, 0, -PI/2, 0.0, ani_sec)
		Vector3.UP:
			return SimpleAnimation.MakeRotationSubfield(ani_name, self, 0, PI/2, 0.0, ani_sec)
		Vector3.RIGHT:
			return SimpleAnimation.MakeRotationSubfield(ani_name, self, 1, PI/2, 0.0, ani_sec)
		Vector3.LEFT:
			return SimpleAnimation.MakeRotationSubfield(ani_name, self, 1, -PI/2, 0.0, ani_sec)
		Vector3.FORWARD:
			return SimpleAnimation.MakeRotationSubfield(ani_name, self, 2, PI/2, 0.0, ani_sec)
		Vector3.BACK:
			return SimpleAnimation.MakeRotationSubfield(ani_name, self, 2, -PI/2, 0.0, ani_sec)

	assert(false, "invalid dir %s" % dir)
	return {}

func make_color_animation(from :Color, to :Color, ani_sec :float, ani_name:String="") -> Dictionary:
	return SimpleAnimation.MakeAnimation(ani_name,self,"color",from,to,ani_sec)
