extends Node3D

const WorldSize := Vector3(40,22,1)

func _ready() -> void:
	get_viewport().size_changed.connect(on_viewport_size_changed)
	var vp_size = get_viewport().get_visible_rect().size
	var 짧은길이 = min(vp_size.x,vp_size.y)
	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)

	set_walls()
	reset_camera_pos()

	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect, tr("gd4template3d 1.0.0"))
	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)

func on_viewport_size_changed():
	pass
	
func message_hidden(_s :String) -> void:
	pass

func set_walls() -> void:
	$WallBox.mesh.size = WorldSize + Vector3(1,1,0)
	$WallBox.position = WorldSize/2 - Vector3(0,0,0.5)
	$OmniLight3D.position = WorldSize/2 + Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2

var camera_move = false
func _process(_delta: float) -> void:
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*WorldSize.x/2, cos(t)*WorldSize.y/2, WorldSize.length()*0.4 ) + WorldSize/2
		$Camera3D.look_at(WorldSize/2)

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()

func _on_카메라변경_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(WorldSize.x/2, WorldSize.y/2, WorldSize.x/2 *1.1)
	$Camera3D.look_at(WorldSize/2)
	$Camera3D.far = WorldSize.length()
