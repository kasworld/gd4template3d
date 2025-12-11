extends Node3D
class_name SlotReel

signal rotation_stopped(rl :SlotReel)
var 번호 :int
var symbol크기 :Vector2
var color_text_info_list :Array # [ color , text ]
var symbol_list :Array[ReelSymbol]
var symbol각도 :float

func calc_radius() -> float:
	return color_text_info_list.size() * symbol크기.y / (2*PI)

func init(n :int, symbol크기a :Vector2, color_text_info_lista :Array) -> SlotReel:
	번호 = n
	symbol크기 = symbol크기a
	color_text_info_list = color_text_info_lista
	var count := color_text_info_list.size()
	symbol각도 = 2*PI / count

	var r := count * symbol크기.y / (2*PI)
	for i in count:
		var k :ReelSymbol = preload("res://slot_reel/reel_symbol/reel_symbol.tscn").instantiate().init(symbol크기.y,r,color_text_info_list[i])
		k.rotation.x = 2*PI/count *i
		add_child(k)
		symbol_list.append(k)

	var spoke := MultiMeshShape.집중선만들기(r*0.99, 0.0, 1.0, symbol크기.x*0.2, 8, Color.WHITE)
	spoke.rotate_y(PI/2)
	add_child( spoke )

	$MeshInstance3D.mesh.material.albedo_color = Color.WHITE
	$MeshInstance3D.mesh.top_radius = calc_radius()
	$MeshInstance3D.mesh.bottom_radius = $MeshInstance3D.mesh.top_radius
	$MeshInstance3D.mesh.height = symbol크기.x
	$MeshInstance3D.mesh.radial_segments = color_text_info_list.size()
	$MeshInstance3D.rotation.x = symbol각도/2

	return self

func _process(delta: float) -> void:
	if 회전중인가:
		돌리기(delta)

var 회전중인가 :bool # need emit
var rotation_per_second :float
var acceleration := 0.3 # per second
func 돌리기(dur_sec :float = 1.0) -> void:
	rotation.x += rotation_per_second * 2 * PI * dur_sec
	if acceleration > 0:
		rotation_per_second *= pow( acceleration , dur_sec)
	if 회전중인가 and (abs(rotation_per_second) <= 0.1 and 중심각차이율(rotation.x) < 0.1 ) or (abs(rotation_per_second) <= 0.01):
		회전중인가 = false
		rotation_per_second = 0.0
		rotation_stopped.emit(self)

# spd : 초당 회전수
func 돌리기시작(spd :float) -> void:
	rotation_per_second = spd
	회전중인가 = true

func 멈추기시작(accel :float=0.5) -> void:
	assert(accel < 1.0)
	acceleration = accel

func symbol중심각도(n :int) -> float:
	return symbol각도 * n

# 0 - 1
func 중심각차이율(rad :float) -> float:
	var 각도차이 := fposmod(rad, symbol각도)
	return 1- abs(각도차이 / symbol각도 - 0.5) *2

func 선택된symbol번호() -> int:
	var 현재각도 = fposmod(-rotation.x, 2*PI)
	return ceili( (현재각도-symbol각도/2) / symbol각도 ) % symbol_list.size()

func 선택된symbol얻기() -> ReelSymbol:
	return symbol_list[선택된symbol번호()]

func debug_str() -> String:
	return "%f %f %f" % [ rad_to_deg(rotation.x), rad_to_deg(symbol각도), 중심각차이율(rotation.x) ]
