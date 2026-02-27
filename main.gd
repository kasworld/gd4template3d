extends Node3D
const WorldSize := Vector3(160,90,80)

func on_viewport_size_changed() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var 짧은길이 :float = min(vp_size.x, vp_size.y)
	var panel_size := Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$"왼쪽패널".size = panel_size
	$"왼쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.size = panel_size
	$"오른쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
	var msgrect := Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(vp_size.y*0.05 , msgrect, "%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version") ] )
func timed_message_hidden(_s :String) -> void:
	pass

func label_demo() -> void:
	if $"오른쪽패널/LabelPerformance".visible:
		$"오른쪽패널/LabelPerformance".text = """%d FPS (%.2f mspf)
Currently rendering: occlusion culling:%s
%d objects
%dK primitive indices
%d draw calls""" % [
		Engine.get_frames_per_second(),1000.0 / Engine.get_frames_per_second(),
		get_tree().root.use_occlusion_culling,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		]
	if $"오른쪽패널/LabelInfo".visible:
		$"오른쪽패널/LabelInfo".text = "%s" % [ MovingCameraLight.GetCurrentCamera() ]

## MovingCameraLight infotext to [camera, sel index]
var mcl_info_to_info :Dictionary[String,Array] = {}
func add_camera_dict(mcl :MovingCameraLight, text :String) -> void:
	mcl.set_info_text(text)
	mcl_info_to_info[text] = [mcl, $"왼쪽패널/SelectCamera".item_count]
	$"왼쪽패널/SelectCamera".add_item(text)
func _on_select_camera_item_selected(index: int) -> void:
	var text :String =  $"왼쪽패널/SelectCamera".get_item_text(index)
	var info :Array = mcl_info_to_info.get(text)
	if info != null :
		focus_to_new_MovingCameraLight(info[0])
	$"왼쪽패널/SelectCamera".release_focus()

func focus_to_new_MovingCameraLight(newmcl :MovingCameraLight) -> void:
	var old := MovingCameraLight.GetCurrentCamera()
	if old.get_parent() is GlassCabinet:
		old.get_parent().set_focus_mode(false)
	newmcl.make_current()
	if newmcl.get_parent() is GlassCabinet:
		newmcl.get_parent().set_focus_mode(true)
		$CabinetDemo.show_all_cabinet(false)
		newmcl.get_parent().visible = true
	else:
		$CabinetDemo.show_all_cabinet(true)

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()
	var mcl := MovingCameraLight.GetCurrentCamera()
	focus_to_new_MovingCameraLight(mcl)
	var text := mcl.get_info_text()
	var info = mcl_info_to_info.get(text)
	if info != null :
		$"왼쪽패널/SelectCamera".select(info[1])

var animate_func :Callable
func _process(delta: float) -> void:
	var now := Time.get_unix_time_from_system()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

	label_demo()
	if not animate_func.is_null():
		animate_func.call(delta)

func _ready() -> void:
	on_viewport_size_changed()
	get_viewport().size_changed.connect(on_viewport_size_changed)
	$TimedMessage.panel_hidden.connect(timed_message_hidden)
	$TimedMessage.show_message("",0)
	$OmniLight3D.omni_range = WorldSize.length()*3
	$CenterCameraLight.set_center_pos_far( Vector3(0, 0, -WorldSize.z), Vector3.ZERO, WorldSize.length()*3)
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightHober.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$MovingCameraLightAround.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	$AxisArrow3D.set_colors().set_size(WorldSize.length()/20)

	add_camera_dict($CenterCameraLight, "Center")
	add_camera_dict($FixedCameraLight, "Fixed")
	add_camera_dict($MovingCameraLightHober, "Hober")
	add_camera_dict($MovingCameraLightAround, "Around")

	$CabinetDemo.init(WorldSize, 2)

	var rundemo :RunDemo = preload("res://run_demo/run_demo.tscn").instantiate()
	add_child(rundemo)

	var run1 := []
	#run1 = [rundemo.snakebyte_demo, "single"]
	if not run1.is_empty() :
		rundemo.init($CabinetDemo.glass_cabinet_list, add_camera_dict, run1)
		var gc :GlassCabinet = rundemo.used_glass_cabinet_iter.get_current()[0]
		focus_to_new_MovingCameraLight(gc.get_camera_light())
	else:
		rundemo.init($CabinetDemo.glass_cabinet_list, add_camera_dict)
		$CenterCameraLight.make_current()

	MovingCameraLight.AllLightOn(false)
	$TourCamera.init_by_glass_cabinet_list($CabinetDemo.glass_cabinet_list)


func _on_끝내기_pressed() -> void:
	get_tree().quit()
func _on_fov_inc_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_inc()
func _on_fov_dec_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_dec()
var key2fn = {
	KEY_ESCAPE:_on_끝내기_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_PAGEUP:_on_fov_inc_pressed,
	KEY_PAGEDOWN:_on_fov_dec_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)
		elif $CenterCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($CenterCameraLight, fi)
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_start_tour_pressed() -> void:
	$CabinetDemo.show_all_cabinet(true)
	$TourCamera.start()

func _on_stop_tour_pressed() -> void:
	$TourCamera.stop()
