extends MultiMeshShape
class_name WireNet

func init(net_size :Vector2, grid_count :Vector2i, wire_width :float, wire_height :float, co :Color, alpha :float = 1.0) -> WireNet:
	var wire_count := Vector2i(grid_count.x +1, grid_count.y +1)
	var pos_shift := -Vector3(net_size.x, net_size.y, 0)/2
	var 선 := BoxMesh.new()
	var count := wire_count.x + wire_count.y
	선.material = make_color_material(alpha)
	init_with_color_mesh(선, count)
	for i in count:
		multimesh.set_instance_color(i,co)
		if i < wire_count.x:
			var pos := Vector3( net_size.x/(wire_count.x-1)* i, net_size.y/2, 0) + pos_shift
			var t := Transform3D(Basis(), pos)
			#t = t.rotated(Vector3(0,1,0), bar_rot)
			t = t.scaled_local( Vector3(wire_width,net_size.y,wire_height) )
			multimesh.set_instance_transform(i,t)
		else:
			var pos := Vector3(net_size.x/2, net_size.y/(wire_count.y-1)* (i-wire_count.x), 0) + pos_shift
			var t := Transform3D(Basis(), pos)
			#t = t.rotated(Vector3(0,1,0), bar_rot)
			t = t.scaled_local( Vector3(net_size.x,wire_width,wire_height) )
			multimesh.set_instance_transform(i,t)
	return self
