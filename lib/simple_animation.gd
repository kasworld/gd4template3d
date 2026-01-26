class_name SimpleAnimation

signal animation_ended(st :Node, ani :Dictionary)

var animation_list :Array[Dictionary]
# {Name,  Node, Field(position, rotation, scale), SubField(0,1,2) , From, To , StartTick, DurSec }

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

func start_move(name :String, aniNode :Node, from :Variant, to: Variant, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"AniNode" : aniNode,
		"Field" : "position",
		"From" : from,
		"To" : to,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_move_subfield(name :String, aniNode :Node, sub_index :int, from :Variant, to: Variant, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"AniNode" : aniNode,
		"Field" : "position",
		"SubField" : sub_index,
		"From" : from,
		"To" : to,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_rotate(name :String, aniNode :Node, from :Variant, to: Variant, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"AniNode" : aniNode,
		"Field" : "rotation",
		"From" : from,
		"To" : to,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_rotate_subfield(name :String, aniNode :Node, sub_index :int, from :Variant, to: Variant, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"AniNode" : aniNode,
		"Field" : "rotation",
		"SubField" : sub_index,
		"From" : from,
		"To" : to,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_scale(name :String, aniNode :Node, from :Variant, to: Variant, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"AniNode" : aniNode,
		"Field" : "scale",
		"From" : from,
		"To" : to,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func start_scale_subfield(name :String, aniNode :Node, sub_index :int, from :Variant, to: Variant, dur_sec :float) -> Dictionary:
	var ani := {
		"Name" : name, # for end signal
		"AniNode" : aniNode,
		"Field" : "scale",
		"SubField" : sub_index,
		"From" : from,
		"To" : to,
		"StartTick" : Time.get_unix_time_from_system(),
		"DurSec" : dur_sec,
	}
	animation_list.append(ani)
	return ani

func handle_animation() -> void:
	var timenow := Time.get_unix_time_from_system()
	for i in animation_list.size():
		var ani :Dictionary = animation_list.pop_front()
		if ani.AniNode == null:
			continue
		var rate :float = (timenow - ani.StartTick) / ani.DurSec
		if rate >= 1.0:
			rate = 1.0
		var fromValue = ani.From
		if fromValue is Node:
			if ani.has("SubField"):
				fromValue = fromValue[ani.Field][ani.SubField]
			else:
				fromValue = fromValue[ani.Field]
		var toValue = ani.To
		if toValue is Node:
			if ani.has("SubField"):
				toValue = toValue[ani.Field][ani.SubField]
			else:
				toValue = toValue[ani.Field]

		if ani.has("SubField"):
			ani.AniNode[ani.Field][ani.SubField] = lerp(fromValue, toValue, rate)
		else:
			ani.AniNode[ani.Field] = fromValue.lerp(toValue, rate)
		if rate >= 1.0:
			animation_ended.emit(ani.AniNode, ani)
		else:
			animation_list.push_back(ani)
