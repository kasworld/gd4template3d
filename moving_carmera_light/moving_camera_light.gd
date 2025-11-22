extends Node3D

class_name MovingCameraLight

static var SelfList :Array[MovingCameraLight]
static var CurrentNumber :int
static func NextCamera() -> void:
	CurrentNumber +=1
	CurrentNumber %= SelfList.size()
	SelfList[CurrentNumber].make_current()
static func GetCurrentCamera() -> MovingCameraLight:
	return SelfList[CurrentNumber]
static func SetCurrentCamera(i :int) -> void:
	CurrentNumber = i
	CurrentNumber %= SelfList.size()
	SelfList[CurrentNumber].make_current()

var number :int
var fov = ClampedFloat.new(75,1,179)

func init(n :int) -> void:
	number = n
	SelfList.append(self)
	fov_reset()

func copy_position_rotation(n :Node3D) -> void:
	position = n.position
	rotation = n.rotation

func _to_string() -> String:
	return "MovingCameraLight%d[FOV:%s, rotation:%s]" % [number, fov, rotation_degrees ]

func fov_inc() -> void:
	$Camera3D.fov = fov.set_up()

func fov_dec() -> void:
	$Camera3D.fov = fov.set_down()

func fov_reset() -> void:
	$Camera3D.fov = fov.reset()

func move_around_y(center :Vector3, radius :float, height :float, spd :float = 2.3) -> void:
	var t := -Time.get_unix_time_from_system() /spd
	position = Vector3( sin(t)*radius, sin(t*1.3)*height, cos(t)*radius ) + center
	look_at(center)

func move_hober_around_z(center :Vector3, radius :float, height :float, spd :float = 2.3) -> void:
	var t := -Time.get_unix_time_from_system() /spd
	position = Vector3(sin(t)*radius, cos(t)*radius, height ) + center
	look_at(center)

func set_center_pos_far(center :Vector3, pos :Vector3, far :float) -> void:
	position = pos
	look_at(center)
	$Camera3D.far = far

func make_current() -> void:
	$Camera3D.current = true
