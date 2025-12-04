extends Node3D

class_name RouletteCell

const 선시작비 = 0.5
const 선끝비 = 1.0

var 칸rad :float
var 반지름 :float
var 깊이 :float
var 색깔 :Color
var 글내용 :String
var 강조중 :bool

func _to_string() -> String:
	return "roulette_cell %s" % [글내용]

func init(각도a :float, 반지름a :float, 깊이a :float, 색깔a :Color, 글내용a :String) -> RouletteCell:
	반지름 = 반지름a
	깊이 = 깊이a
	색깔 = 색깔a

	$"시작선".mesh.size = Vector3(반지름*(선끝비 - 선시작비), 깊이, 깊이 /10)
	#$"글씨".mesh.font = Global3d.font
	$"글씨".mesh.depth = 깊이
	$"글씨".mesh.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
	$"글씨".rotation = Vector3(-PI/2,0,-PI/2)
	$"글씨".position = Vector3(0, 깊이/2, 반지름)
	색깔바꾸기(색깔a)
	글내용바꾸기(글내용a)
	칸rad바꾸기(각도a)
	글씨크기바꾸기()
	return self

func 칸rad바꾸기(새각도 :float) -> void:
	칸rad = 새각도
	$"시작선".rotation.y = 칸rad/2+PI/2
	var rad = 칸rad/2
	$"시작선".position = Vector3(sin(rad)*반지름*(선끝비 + 선시작비)/2, 깊이/2, cos(rad)*반지름*(선끝비 + 선시작비)/2)

func 글내용바꾸기(새글내용 :String) -> void:
	글내용 = 새글내용
	$"글씨".mesh.text = 글내용

func 색깔바꾸기(새색깔 :Color) -> void:
	색깔 = 새색깔
	$"시작선".mesh.material.albedo_color = 색깔
	$"글씨".mesh.material.albedo_color = 색깔

func 글씨크기바꾸기() -> void:
	$"글씨".mesh.pixel_size = 반지름 *sin(칸rad) *0.05

func 강조상태켜기() -> void:
	if $AnimationPlayer.is_playing():
		return
	강조중 = true
	#$"글씨".scale.x = 2.0
	$AnimationPlayer.play("글씨강조")

func 강조상태끄기() -> void:
	강조중 = false
	#$"글씨".scale.x = 1.0
	$AnimationPlayer.play("글씨강조끄기")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"글씨강조":
			강조상태끄기.call_deferred()
		"글씨강조끄기":
			pass
