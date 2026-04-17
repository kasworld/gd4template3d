extends Node3D
class_name ManhwaEye

func set_radius(outer_r :float, inner_rate :float = 0.6) -> void:
	$Outer.mesh.radius = outer_r
	$Outer.mesh.height = outer_r * 0.4
	$Inner.mesh.radius = outer_r * inner_rate
	$Inner.mesh.height = outer_r * 0.4

func set_color(outer_co :Color, inner_co :Color) -> void:
	$Outer.mesh.material.albedo_color = outer_co
	$Inner.mesh.material.albedo_color = inner_co
