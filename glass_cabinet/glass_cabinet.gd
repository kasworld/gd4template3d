extends Node3D
class_name GlassCabinet

var focus_mode :bool
signal focus_mode_changed(me :GlassCabinet, mode :bool)
func set_focus_mode(b :bool) -> void:
	focus_mode = b
	focus_mode_changed.emit(self, focus_mode)
func get_focus_mode() -> bool:
	return focus_mode

var cabinet_size :Vector3
func get_aabb() -> AABB:
	return AABB(-cabinet_size/2, cabinet_size)

func make_CalcGrid3D(grid :Vector3i) -> CalcGrid3D:
	return CalcGrid3D.new(get_aabb(), grid)

func init(cabinet_size_a :Vector3) -> GlassCabinet:
	cabinet_size = cabinet_size_a
	$WallBox.mesh.size = cabinet_size
	var camera_pos := Vector3(0, 0, $FixedCameraLight.calc_z_len_by_fov_size(cabinet_size) + cabinet_size.z)
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, camera_pos, cabinet_size.length()*2)
	$AxisArrow3D.set_size(cabinet_size.length()/10).set_colors()
	$Title.pixel_size = cabinet_size.y/300
	$Title.position = Vector3(-cabinet_size.x/2,cabinet_size.y/2,cabinet_size.z/2)
	$Description.pixel_size = cabinet_size.y/600
	$Description.position = Vector3(cabinet_size.x/2,-cabinet_size.y/2,cabinet_size.z/2)
	$WireBox.init_wire_box( cabinet_size, cabinet_size.length()/200, Color.WHITE)
	$Points.init_spheres_by_point_list(
		PlatonicSolids.MultiplyPointList(PlatonicSolids.CubePoints, cabinet_size/2),
		cabinet_size.length()/200, Color.WHITE,
	)
	add_spot_lights()
	return self

var animate_func_list :Array[Callable] = []
func add_animate_func(fn :Callable) -> void:
	animate_func_list.append(fn)
func process_animation(delta :float) -> void:
	for fn in animate_func_list:
		fn.call(delta)
func add_light_animation_to_animate_func_list() -> void:
	animate_func_list.append(animate_light)

## x+ , x-
var ani_state := [AnimateGradient.new(), AnimateGradient.new()]
func animate_light(_delta) -> void:
	for i in ani_state.size():
		var flags :=  GroupFlags[ GroupFlags.keys()[i] ]
		set_light_color(ani_state[i].get_color(), flags)
		ani_state[i].inc_rate(0.1)


func add_spot_lights() -> GlassCabinet:
	var points := PlatonicSolids.MultiplyPointList(PlatonicSolids.CubePoints, cabinet_size/2 )
	for pos in points:
		var sl := SpotLight3D.new()
		$LightContainer.add_child(sl)
		sl.spot_range = cabinet_size.length()
		sl.position = pos
		sl.look_at_from_position(pos, Vector3.ZERO)
		sl.light_energy = 100
		#sl.shadow_enabled = true
		#sl.light_color = Color.RED
		light_list.append(sl)
	return self

#const CubePoints := [
	#Vector3(1,1,1),
	#Vector3(-1,1,1),
	#Vector3(1,-1,1),
	#Vector3(-1,-1,1),
	#Vector3(1,1,-1),
	#Vector3(-1,1,-1),
	#Vector3(1,-1,-1),
	#Vector3(-1,-1,-1),
#]

func show_axis_arrow(b :bool = true) -> GlassCabinet:
	$AxisArrow3D.visible = b
	return self

func show_wall_box(b :bool = true) -> GlassCabinet:
	$WallBox.visible = b
	return self
func set_wall_box_color(co :Color) -> GlassCabinet:
	$WallBox.mesh.material.albedo_color = co
	return self

func show_wire_box(b :bool = true) -> GlassCabinet:
	$WireBox.visible = b
	return self
func set_wire_box_color(co :Color) -> GlassCabinet:
	$WireBox.set_color_all(co)
	return self

func show_points(b :bool = true) -> GlassCabinet:
	$Points.visible = b
	return self
func set_points_color(co :Color) -> GlassCabinet:
	$Points.set_color_all(co)
	return self

func get_title_text() -> String:
	return $Title.text
func show_title(b :bool = true) -> GlassCabinet:
	$Title.visible = b
	return self
func set_title_text(t :String) -> GlassCabinet:
	$Title.text = t
	return self
func set_title_pixel_size(sz :float) -> GlassCabinet:
	$Title.pixel_size = sz
	return self

func get_description_text() -> String:
	return $Description.text
func show_description(b :bool = true) -> GlassCabinet:
	$Description.visible = b
	return self
func set_description_text(t :String) -> GlassCabinet:
	$Description.text = t
	return self
func set_description_pixel_size(sz :float) -> GlassCabinet:
	$Description.pixel_size = sz
	return self


func get_camera_light() -> MovingCameraLight:
	return $FixedCameraLight

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)



## light list functions

## axis : x:0, y:1, z:2, axis_sign : 1,0,-1
static func MakeGroupFlags(axis :int, axis_sign :int) -> int:
	var pos_list := PlatonicSolids.CubePoints
	var rtn := 0
	for i in pos_list.size():
		if sign(pos_list[i][axis]) == sign(axis_sign) :
			rtn = BitFlag.SetByPos(i,rtn)
	return rtn

static var GroupFlags :Dictionary[String,int] = {
		"x+" : MakeGroupFlags(Vector3.Axis.AXIS_X,+1),
		"x-" : MakeGroupFlags(Vector3.Axis.AXIS_X,-1),
		"y+" : MakeGroupFlags(Vector3.Axis.AXIS_Y,+1),
		"y-" : MakeGroupFlags(Vector3.Axis.AXIS_Y,-1),
		"z+" : MakeGroupFlags(Vector3.Axis.AXIS_Z,+1),
		"z-" : MakeGroupFlags(Vector3.Axis.AXIS_Z,-1),
	}

static var BitFlagAllLight :int = BitFlag.MakeFilledFlags(PlatonicSolids.CubePoints.size())
var light_list :Array
func get_light_list() -> Array:
	return light_list

## set field by index
static func SetArray_field_value_at_index(list:Array, index :int, field:String, value :Variant) -> void:
	list[index][field] = value

## not bool field
static func GetArray_from_field(list:Array, field :String) -> Array:
	var rtn := []
	for lt in list:
		rtn.append(lt[field])
	return rtn

## flag bit == 1 , set light_energy
func set_light_energy(v :float, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list, flags, "light_energy", v)

func set_light_energy_at(i :int, v :float) -> void:
	SetArray_field_value_at_index(light_list, i, "light_energy", v)

func set_light_color(co :Color, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list,flags, "light_color", co)

func set_light_color_at(i :int, co :Color) -> void:
	SetArray_field_value_at_index(light_list, i, "light_color", co)

## flag bit == 1 , set visible to b
func set_light_on(b :bool, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list,flags, "visible", b)

func set_light_on_at(i :int, b :bool) -> void:
	SetArray_field_value_at_index(light_list, i, "visible", b)

## all light on/off by flag
func set_light_on_all(flags :int) -> void:
	BitFlag.SetArray_bool_by_flag(light_list, flags, "visible")

## flag bit == 1 , set light shadow to b
func set_light_shadow(b :bool, flags :int) -> void:
	BitFlag.SetArray_value_at_flag_true(light_list,flags, "shadow_enabled", b)

func set_light_shadow_at(i :int, b :bool) -> void:
	SetArray_field_value_at_index(light_list, i, "shadow_enabled", b)

## all light shadow on/off by flag
func set_light_shadow_all(flags :int) -> void:
	BitFlag.SetArray_bool_by_flag(light_list, flags, "shadow_enabled")

func get_light_on_all() -> int:
	return BitFlag.GetArray_flags_from_bool_field(light_list,"visible")

func get_light_shadow_all() -> int:
	return BitFlag.GetArray_flags_from_bool_field(light_list,"shadow_enabled")

func get_light_color_all() -> Array:
	return GetArray_from_field(light_list, "light_color")
