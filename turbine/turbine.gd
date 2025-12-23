extends Node3D
class_name Turbine

func init(r :float, w :float, arm :int, co :Color) -> Turbine:
	날개만들기(r, 0.01, 0.99, w, arm, co)
	#spoke.rotate_y(PI/2)

	$Reel.mesh.material.albedo_color = co
	$Reel.mesh.inner_radius = r*0.99
	$Reel.mesh.outer_radius = r
	$Reel.scale = Vector3(1,8,1)
	#$Reel.mesh.top_radius = r
	#$Reel.mesh.bottom_radius = $Reel.mesh.top_radius
	#$Reel.mesh.height = w
	#$Reel.mesh.radial_segments = 64
	$Reel.rotate_x(PI/2)
	return self

func 날개만들기(r :float, start:float, end:float, depth :float, count :int, co :Color ) -> void:
	var 구분선 := BoxMesh.new()
	var 길이 := r*(end-start)
	구분선.size = Vector3(길이, depth/10, depth )
	var cell각도 := 2.0*PI / count
	var radius := r-길이/2
	$"날개들".init_with_alpha(구분선, count, 1.0)
	for i in count:
		var rad := cell각도 *i + cell각도/2
		$"날개들".set_inst_rotation(i, Vector3.BACK, rad)
		$"날개들".set_inst_rotation(i, Vector3.LEFT, PI/10)
		$"날개들".set_inst_position(i, Vector3(cos(rad) *radius,sin(rad) *radius, 0) )
		$"날개들".set_inst_color(i, co)
