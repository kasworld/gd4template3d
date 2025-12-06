extends Node3D

class_name RouletteCell

const 선시작비 := 0.5
const 선끝비 := 1.0
const 선중심비 := (선끝비 + 선시작비)/2

var 강조중 :bool

func init(각도 :float, 반지름 :float, 깊이 :float, color_text_info :Array) -> RouletteCell:
	$"시작선".mesh.size = Vector3(반지름*(선끝비 - 선시작비), 깊이, 깊이 /10)
	$"시작선".rotation.y = 각도/2 +PI/2
	$"시작선".position = Vector3(sin(각도/2)*반지름*선중심비, 깊이/2, cos(각도/2)*반지름*선중심비)
	$"시작선".mesh.material.albedo_color = color_text_info[0]

	$"글씨".mesh.depth = 깊이
	$"글씨".mesh.pixel_size = 반지름 *sin(각도) *0.05
	$"글씨".mesh.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
	$"글씨".rotation = Vector3(-PI/2,0,-PI/2)
	$"글씨".position = Vector3(0, 깊이/2, 반지름)
	$"글씨".mesh.text = color_text_info[1]
	$"글씨".mesh.material.albedo_color = color_text_info[0]
	return self

func 글내용얻기() -> String:
	return $"글씨".mesh.text

func 강조상태켜기() -> void:
	if $AnimationPlayer.is_playing():
		return
	강조중 = true
	$AnimationPlayer.play("글씨강조")

func 강조상태끄기() -> void:
	강조중 = false
	$AnimationPlayer.play("글씨강조끄기")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"글씨강조":
			강조상태끄기.call_deferred()
		"글씨강조끄기":
			pass
