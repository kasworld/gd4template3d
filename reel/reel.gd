extends Node3D
class_name Reel

signal rotation_stopped(rl :Reel)
var 번호 :int
var symbol크기 :Vector2
var symbol정보목록 :Array # [ text, color ]
var symbol_list :Array[ReelSymbol]
var symbol각도 :float

func calc_radius() -> float:
	return symbol정보목록.size() * symbol크기.y / (2*PI)

func init(n :int, symbol크기a :Vector2, symbol정보목록a :Array) -> Reel:
	번호 = n
	symbol크기 = symbol크기a
	symbol정보목록 = symbol정보목록a
	var count := symbol정보목록.size()
	symbol각도 = 2*PI / count

	var r := count * symbol크기.y / (2*PI)
	for i in count:
		var k :ReelSymbol = preload("res://reel/reel_symbol/reel_symbol.tscn").instantiate().init(i, symbol크기,r,symbol정보목록[i][0], symbol정보목록[i][1])
		k.rotation.x = 2*PI/count *i
		add_child(k)
		symbol_list.append(k)

	$MeshInstance3D.mesh.material.albedo_color = Color.WHITE
	$MeshInstance3D.mesh.top_radius = calc_radius()
	$MeshInstance3D.mesh.bottom_radius = $MeshInstance3D.mesh.top_radius
	$MeshInstance3D.mesh.height = symbol크기.x
	$MeshInstance3D.mesh.radial_segments = symbol정보목록.size()
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
	#if 회전중인가 and abs(rotation_per_second) <= 0.01:
	if 회전중인가 and (abs(rotation_per_second) <= 0.1 and symbol중심근처인가()) or (abs(rotation_per_second) <= 0.01):
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

func symbol중심근처인가() -> bool:
	var 현재각도 = fposmod(-rotation.x, 2*PI)
	var 중심각도 = symbol중심각도(선택된symbol번호())
	return abs(현재각도 - 중심각도) <= symbol각도/100

func 선택된symbol번호() -> int:
	var 현재각도 = fposmod(-rotation.x, 2*PI)
	return ceili( (현재각도-symbol각도/2) / symbol각도 ) % symbol_list.size()

func 선택된symbol얻기() -> ReelSymbol:
	return symbol_list[선택된symbol번호()]
