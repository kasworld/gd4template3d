class_name BattleShooterAI

static func connect_if_not(sg :Signal, fn :Callable) -> void:
	if not sg.is_connected(fn):
		sg.connect(fn)


static func rand_per_sec(delta :float, per_sec :float) -> bool:
	return randf() < per_sec*delta

static func not_null_and_alive(o :Area3D) -> bool:
	return o != null and o.alive

static func find_other_team_ship(ship_list :Array[BSObj], t_num :int) -> BSObj: # Ship
	if ship_list.size() == 0:
		return null
	var dst :BSObj # Ship
	var try := 10
	while try > 0 :
		dst = ship_list.pick_random()
		if dst != null and dst.type == BSObj.Type.Ship and dst.alive and dst.team_number != t_num:
			return dst
		try -= 1
	return null

# larger is danger
static func calc_danger_level(me :BSObj, dst :Area3D) -> float:
	var delta := 1.0/60.0
	var l1 := dst.global_position.distance_squared_to(me.global_position)
	var l2 :float = (dst.global_position + dst.velocity *delta).distance_squared_to(me.global_position + me.velocity *delta)
	if l1 > l2 : # approaching
		return 100000.0/l1
	else:
		return 0

static func find_danger_objs(me :BSObj, node_list :Array[BSObj]) -> Dictionary:
	var rtn := {
		"All":[null, 0.0],
		"Ship":[null, 0.0],
		"Bullet":[null, 0.0],
		"Homming":[null, 0.0],
	}
	if not me.alive:
		return rtn
	for o in node_list:
		if me.team_number == o.team_number:
			continue
		if not me.alive:
			continue
		var dval := BattleShooterAI.calc_danger_level(me, o)
		if dval > rtn.All[1]:
			rtn.All = [o, dval]
		if o.type == BSObj.Type.Ship:
			if dval > rtn.Ship[1]:
				rtn.Ship = [o, dval]
		elif o.type == BSObj.Type.Bullet:
			if dval > rtn.Bullet[1]:
				rtn.Bullet = [o, dval]
		elif o.type == BSObj.Type.Homming:
			if dval > rtn.Homming[1]:
				rtn.Homming = [o, dval]
	return rtn

static func accel_to_evade(world_size:Vector3, pos: Vector3, velocity :Vector3, o :Area3D) -> Vector3:
	if not BattleShooterAI.not_null_and_alive(o):
		return velocity
	var axis := pos.cross(o.position).normalized()
	var max_speed := BSObj.CalcRefSpeed(BSObj.Type.Ship)
	if pos.distance_squared_to(world_size/2) < (world_size/4).length_squared(): # evade to backward
		velocity = (pos - o.global_position).normalized()*max_speed
		velocity = velocity.rotated(axis, (randf()-0.5)*PI/8)
		velocity = velocity.limit_length(max_speed)
	else: # evade to center
		velocity = to_center(pos, o.global_position, world_size/2) * max_speed
		velocity = velocity.rotated(axis, (randf()-0.5)*PI/8)
		velocity = velocity.limit_length(max_speed)
	return velocity

static func to_center(p1 :Vector3, p2 :Vector3, center :Vector3) -> Vector3:
	var axis := p1.cross(p2).normalized()
	var vt := p1.direction_to(p2)
	var ot := vt.rotated(axis, PI/2)
	if p1.direction_to(center).dot(ot) > 0:
		return ot # face to center?
	else:
		return -ot

static func do_fire_bullet(from_pos :Vector3, t_num :int, delta :float, danger_dict :Dictionary, ship_list :Array[BSObj]) -> Vector3:
#	var danger_dict = {
#		"All":[null, 0.0],
#		"Ship":[null, 0.0],
#		"Bullet":[null, 0.0],
#		"Homming":[null, 0.0],
#	}
	if not BattleShooterAI.rand_per_sec(delta, 5.0):
		return Vector3.ZERO
	var dst :Area3D
	if danger_dict.Ship[1] > danger_dict.Bullet[1]:
		dst = danger_dict.Ship[0]
	else:
		dst = danger_dict.Bullet[0]
	if dst == null:
		dst = find_other_team_ship(ship_list, t_num)
	if dst == null:
		return Vector3.ZERO
	var v := BattleShooterAI.calc_aim_vector3(from_pos, BSObj.CalcRefSpeed(BSObj.Type.Bullet), dst.global_position, dst.velocity )
	return v

static func calc_aim_vector3(src_pos :Vector3, src_speed :float, dst_pos :Vector3, dst_vel :Vector3 ) -> Vector3:
	var axis := src_pos.cross(dst_pos).normalized()
	var vt := dst_pos - src_pos
	var dst_speed := dst_vel.length()
	if dst_speed == 0 :
		return vt
	var a2 := vt.signed_angle_to(dst_vel, axis)
	var a1 := asin(dst_speed/src_speed * sin(a2))
	var rtn := vt.rotated(axis, a1).normalized() * src_speed
	return rtn


static func do_fire_homming(t_num :int, delta :float, danger_dict :Dictionary, ship_list :Array[BSObj]) -> Area3D:
#	var danger_dict = {
#		"All":[null, 0.0],
#		"Ship":[null, 0.0],
#		"Bullet":[null, 0.0],
#		"Homming":[null, 0.0],
#	}
	if not BattleShooterAI.rand_per_sec(delta, 2.0):
		return null

	var dst :Area3D
	if danger_dict.Ship[1] > danger_dict.Homming[1]:
		dst = danger_dict.Ship[0]
	else:
		dst = danger_dict.Homming[0]
	if dst == null:
		dst = find_other_team_ship(ship_list, t_num)
	return dst

static func do_add_shield(delta :float) -> bool:
	if not BattleShooterAI.rand_per_sec(delta, 2.0):
		return false
	return true
