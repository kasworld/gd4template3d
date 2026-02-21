extends Node3D
class_name Monomino

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
