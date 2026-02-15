class_name BattleShooterTeam

var stats :Dictionary[String,int] = {
	ShipNow = 0,
	ShipMax = 0,
	Accel = 0,
	NewShip = 0,
	NewShield = 0,
	NewBullet = 0,
	NewHomming = 0,
	KillShip = 0,
	KillShield = 0,
	KillBullet = 0,
	KillHomming = 0,
}

func _to_string() -> String:
	var rtn := "%s " % [name]
	for k in stats:
		rtn += "%s:%d " %[k, stats[k]]
	return rtn

var color :Color
var name :String
func _init(co :Color, ship_per_team :int) -> void:
	color = co
	name = NamedColors.get_colorname_by_color(co)
	for k in stats:
		stats[k] = 0
	set_ship_count_limit(ship_per_team)

func calc_tomake_ship() -> int:
	return stats.ShipMax - stats.ShipNow

func inc_ship_count() -> void:
	stats.ShipNow += 1

func dec_ship_count() -> void:
	stats.ShipNow -= 1

func set_ship_count_limit(v :int) -> void:
	stats.ShipMax = v
