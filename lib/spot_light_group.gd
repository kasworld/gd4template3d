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

## set field value at flag true
func set_value_at_flag_true(flags :int, field:String, value :Variant) -> void:
	for i in light_list.size():
		if BitFlag.TestByPos(i, flags):
			light_list[i][field] = value

## set field by index
func set_value_at_index(index :int, field:String, value :Variant) -> void:
	light_list[index][field] = value

## set all bool field by flag value
func set_bool_by_flag(flags :int, field:String) -> void:
	for i in light_list.size():
		light_list[i][field] = BitFlag.TestByPos(i, flags)

## bool field only
func make_flags_from_bool_field(field :String) -> int:
	var rtn := 0
	for i in light_list.size():
		BitFlag.SetByPos(i, light_list[i][field])
	return rtn

## not bool field
func make_array_from_field(field :String) -> Array:
	var rtn := []
	for lt in light_list:
		rtn.append(lt[field])
	return rtn


## flag bit == 1 , set light_energy
func set_light_energy(v :float, flags :int) -> void:
	set_value_at_flag_true(flags, "light_energy", v)

func set_light_energy_at(i :int, v :float) -> void:
	set_value_at_index(i, "light_energy", v)

func set_light_color(co :Color, flags :int) -> void:
	set_value_at_flag_true(flags, "light_color", co)

func set_light_color_at(i :int, co :Color) -> void:
	set_value_at_index(i, "light_color", co)

## flag bit == 1 , set visible to b
func set_light_on(b :bool, flags :int) -> void:
	set_value_at_flag_true(flags, "visible", b)

func set_light_on_at(i :int, b :bool) -> void:
	set_value_at_index(i, "visible", b)

## all light on/off by flag
func set_light_on_all(flags :int) -> void:
	set_bool_by_flag(flags, "visible")

## flag bit == 1 , set light shadow to b
func set_light_shadow(b :bool, flags :int) -> void:
	set_value_at_flag_true(flags, "shadow_enabled", b)

func set_light_shadow_at(i :int, b :bool) -> void:
	set_value_at_index(i, "shadow_enabled", b)

## all light shadow on/off by flag
func set_light_shadow_all(flags :int) -> void:
	set_bool_by_flag(flags, "shadow_enabled")


func get_light_on_all() -> int:
	return make_flags_from_bool_field("visible")

func get_light_shadow_all() -> int:
	return make_flags_from_bool_field("shadow_enabled")

func get_light_color_all() -> Array:
	return make_array_from_field("light_color")
