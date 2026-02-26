class_name SpotLightGroup

var light_list :Array[SpotLight3D]

func make_pos_list() -> Array[int]:
	return BitFlag.MakeFilledPosList(light_list.size())

func get_size() -> int:
	return light_list.size()

## arg is Node or Array
func _init(arg ) -> void:
	light_list = []
	if arg is Node:
		for sl in arg.get_children():
			light_list.append(sl)
	elif arg is Array:
		for sl in arg:
			light_list.append(sl)
	else:
		assert(false)

## set field by index
func set_value_at_index(index :int, field:String, value :Variant) -> void:
	light_list[index][field] = value

## not bool field
func make_array_from_field(field :String) -> Array:
	var rtn := []
	for lt in light_list:
		rtn.append(lt[field])
	return rtn


## flag bit == 1 , set light_energy
func set_light_energy(v :float, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list, flags, "light_energy", v)

func set_light_energy_at(i :int, v :float) -> void:
	set_value_at_index(i, "light_energy", v)

func set_light_color(co :Color, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list,flags, "light_color", co)

func set_light_color_at(i :int, co :Color) -> void:
	set_value_at_index(i, "light_color", co)

## flag bit == 1 , set visible to b
func set_light_on(b :bool, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list,flags, "visible", b)

func set_light_on_at(i :int, b :bool) -> void:
	set_value_at_index(i, "visible", b)

## all light on/off by flag
func set_light_on_all(flags :int) -> void:
	BitFlag.SetArray_bool_by_flag(light_list, flags, "visible")

## flag bit == 1 , set light shadow to b
func set_light_shadow(b :bool, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list,flags, "shadow_enabled", b)

func set_light_shadow_at(i :int, b :bool) -> void:
	set_value_at_index(i, "shadow_enabled", b)

## all light shadow on/off by flag
func set_light_shadow_all(flags :int) -> void:
	BitFlag.SetArray_bool_by_flag(light_list, flags, "shadow_enabled")

func get_light_on_all() -> int:
	return BitFlag.GetArray_flags_from_bool_field(light_list,"visible")

func get_light_shadow_all() -> int:
	return BitFlag.GetArray_flags_from_bool_field(light_list,"shadow_enabled")

func get_light_color_all() -> Array:
	return make_array_from_field("light_color")
