extends Node3D
class_name Slots

signal rotation_stopped(s :Slots)

var reel_list := []
func init(reelcount :int, symbol크기 :Vector2, color_text_info_list: Array) -> Slots:
	var total_width := reelcount*(symbol크기.x+1)
	for i in reelcount:
		var kilist := color_text_info_list.duplicate()#.slice(0,7)
		kilist.shuffle()
		var rl = preload("res://slot_reel/slot_reel.tscn").instantiate().init(i, symbol크기, kilist)
		rl.rotation_stopped.connect(결과가결정됨)
		rl.position = Vector3(i*symbol크기.x+i +symbol크기.x/2 -total_width/2, 0, 0)
		add_child(rl)
		reel_list.append(rl)

	$Bar.mesh.material.albedo_color = Color.GOLD
	$Bar.mesh.top_radius = 0.1
	$Bar.mesh.bottom_radius = $Bar.mesh.top_radius
	$Bar.mesh.height = total_width
	$Bar.position = (reel_list[-1].position + reel_list[0].position) /2 + Vector3(0,0,reel_list[0].calc_radius())

	return self

func calc_radius() -> float:
	return reel_list[0].calc_radius()

func 결과가결정됨( _rl :SlotReel) -> void:
	var 모두멈추었나 = true
	for n in reel_list:
		if n.회전중인가:
			모두멈추었나 = false

	if 모두멈추었나:
		rotation_stopped.emit(self)

func 선택된symbol들얻기() -> Array:
	var rtn := []
	for n in reel_list:
		rtn.append(n.선택된symbol얻기())
	return rtn

func random_color()->Color:
	return NamedColorList.color_list.pick_random()[0]

func 돌리기시작() -> void:
	for r in reel_list:
		var rot = randfn(2*PI, PI/2)
		if randi_range(0,1) == 0:
			rot = -rot
		r.돌리기시작(rot)
