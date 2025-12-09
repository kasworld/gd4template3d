extends Node3D
class_name RouletteCell

var 강조중 :bool

func init(각도 :float, 반지름 :float, 깊이 :float, color_text_info :Array) -> RouletteCell:
	$"글씨".mesh.depth = 깊이
	$"글씨".mesh.pixel_size = 반지름 *sin(각도) *0.04
	$"글씨".mesh.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
	$"글씨".position = Vector3(반지름, 0, 0 )
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
