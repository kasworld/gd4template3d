extends Node3D
class_name CabinetDemo

var glass_cabinet_row_list :Array[Node3D]
var glass_cabinet_list :Array[GlassCabinet]
var row_rotate_speed :Array[float] = []

func init(cabinet_size :Vector3, row_count := 2) -> void:
	for i in row_count: # glass_cabinet_row
		var gcr := make_glass_cabinet_row(cabinet_size, 12, i)
		add_child(gcr)
		glass_cabinet_row_list.append(gcr)
		gcr.position.y = cabinet_size.y *(float(i)-float(row_count-1)/2) * 1.05
		for gc in gcr.get_children():
			glass_cabinet_list.append(gc)
	set_rot_speed()

func make_glass_cabinet_row(cabinet_size :Vector3, count :int, row :int) -> Node3D:
	var rtn := Node3D.new()
	var unit_rad := 2*PI/ count
	var radius := cabinet_size.x *count / (PI *2) + cabinet_size.z/2
	for i in count:
		var gc :GlassCabinet = preload("res://glass_cabinet/glass_cabinet.tscn").instantiate(
			).init(cabinet_size)
		var rad := i * unit_rad
		gc.position = Vector3(sin(rad)*radius, 0, cos(rad)*radius)
		gc.set_title_text("%d-%d" % [row+1, i+1]).show_title(true)
		gc.look_at_from_position(gc.position, Vector3.ZERO, Vector3.UP, true)
		gc.set_light_on_all(0b00000011) # x+,x-
		#gc.set_light_on(false, gc.GroupFlags.z_n)
		#gc.set_light_on(false, gc.GroupFlags.y_n)
		#gc.set_light_on(false, gc.GroupFlags.x_n)
		rtn.add_child(gc)
	return rtn

func show_all_cabinet(b :bool = true) -> void:
	for gcl in glass_cabinet_list:
		gcl.visible = b

func set_rot_speed() -> void:
	row_rotate_speed.resize(glass_cabinet_row_list.size())
	for i in row_rotate_speed.size():
		var rot_speed := randf_range(0.1,0.3)
		if randi()%2==0:
			rot_speed = -rot_speed
		row_rotate_speed[i] = rot_speed

func _process(delta: float) -> void:
	for i in glass_cabinet_row_list.size():
		glass_cabinet_row_list[i].rotate_y(delta*row_rotate_speed[i])
