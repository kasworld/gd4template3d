extends Node3D
class_name WireNet

var net_size :Vector2
var wire_count :Vector2i
var wire_radius :float

func init(net_sizea :Vector2, wire_counta :Vector2i, wire_r :float) -> WireNet:
	net_size = net_sizea
	wire_count = wire_counta
	wire_radius = wire_r
	#var co := Color.RED
	
	$MultiMeshInstance3D.multimesh.instance_count = wire_count.x + wire_count.y
	$MultiMeshInstance3D.multimesh.visible_instance_count = $MultiMeshInstance3D.multimesh.instance_count
	for i in $MultiMeshInstance3D.multimesh.visible_instance_count:
		if i < wire_count.x:
			$MultiMeshInstance3D.multimesh.set_instance_color(i,Color.RED)
			var pos := Vector3( net_size.x/(wire_count.x-1)* i, net_size.y/2, 0)
			var t = Transform3D(Basis(), pos)
			#t = t.rotated(Vector3(0,1,0), bar_rot)
			t = t.scaled_local( Vector3(wire_radius,net_size.y,wire_radius) )
			$MultiMeshInstance3D.multimesh.set_instance_transform(i,t)
		else:
			$MultiMeshInstance3D.multimesh.set_instance_color(i,Color.BLUE)
			var pos := Vector3(net_size.x/2, net_size.y/(wire_count.y-1)* (i-wire_count.x), 0)
			var t = Transform3D(Basis(), pos)
			#t = t.rotated(Vector3(0,1,0), bar_rot)
			t = t.scaled_local( Vector3(net_size.x,wire_radius,wire_radius) )
			$MultiMeshInstance3D.multimesh.set_instance_transform(i,t)

	return self
