class_name Animation2D

signal animation_ended(st :Node2D, ani :Dictionary)

var animation_list :Array[Dictionary]
# {Name,  Node2d, Field(position, rotation, scale), SubField(0,1,2) , StartValue, EndValue , StartTick, DurSec }

func get_animation_count() -> int:
	return animation_list.size()

func is_empty() -> bool:
	return animation_list.is_empty()

func is_Name_exist(name :String) -> bool:
	for d in animation_list:
		if d.Name == name:
			return true
	return false

func find_by_Name(name :String) -> Array[Dictionary]:
	var rtn :Array[Dictionary]
	for d in animation_list:
		if d.Name == name:
			rtn.append(d)
	return rtn

func is_Field_exist(field :String) -> bool:
	for d in animation_list:
		if d.Field == field:
			return true
	return false

func find_by_Field(field :String) -> Array[Dictionary]:
	var rtn :Array[Dictionary]
	for d in animation_list:
		if d.Field == field:
			rtn.append(d)
	return rtn

func start_move(name :String, node :Node2D, src_val :Vector2, dst_val: Vector2, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"Node2D" : node,
		"Field" : "position",
		"StartValue" : src_val,
		"EndValue" : dst_val,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_move_subfield(name :String, node :Node2D, sub_index :int, src_val :float, dst_val: float, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"Node2D" : node,
		"Field" : "position",
		"SubField" : sub_index,
		"StartValue" : src_val,
		"EndValue" : dst_val,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_rotate(name :String, node :Node2D, src_val :Vector2, dst_val: Vector2, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"Node2D" : node,
		"Field" : "rotation",
		"StartValue" : src_val,
		"EndValue" : dst_val,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_rotate_subfield(name :String, node :Node2D, sub_index :int, src_val :float, dst_val: float, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"Node2D" : node,
		"Field" : "rotation",
		"SubField" : sub_index,
		"StartValue" : src_val,
		"EndValue" : dst_val,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani


func start_scale(name :String, node :Node2D, src_val :Vector2, dst_val: Vector2, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"Node2D" : node,
		"Field" : "scale",
		"StartValue" : src_val,
		"EndValue" : dst_val,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_scale_subfield(name :String, node :Node2D, sub_index :int, src_val :float, dst_val: float, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"Node2D" : node,
		"Field" : "scale",
		"SubField" : sub_index,
		"StartValue" : src_val,
		"EndValue" : dst_val,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func handle_animation() -> void:
	var timenow := Time.get_unix_time_from_system()
	for i in animation_list.size():
		var ani :Dictionary = animation_list.pop_front()
		if ani.Node2D == null:
			continue
		var rate :float = (timenow - ani.StartTick) / ani.DurSec
		if rate >= 1.0:
			rate = 1.0
		match ani.Field:
			"position":
				if ani.has("SubField"):
					ani.Node2D.position[ani.SubField] = lerpf(ani.StartValue, ani.EndValue, rate)
				else:
					ani.Node2D.position = ani.StartValue.lerp(ani.EndValue, rate)
			"rotation":
				if ani.has("SubField"):
					ani.Node2D.rotation[ani.SubField] = lerpf(ani.StartValue, ani.EndValue, rate)
				else:
					ani.Node2D.rotation = ani.StartValue.lerp(ani.EndValue, rate)
			"scale":
				if ani.has("SubField"):
					ani.Node2D.scale[ani.SubField] = lerpf(ani.StartValue, ani.EndValue, rate)
				else:
					ani.Node2D.scale = ani.StartValue.lerp(ani.EndValue, rate)
		if rate >= 1.0:
			animation_ended.emit(ani.Node2D, ani)
		else:
			animation_list.push_back(ani)
