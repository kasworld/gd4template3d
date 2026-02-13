class_name BattleShooterTeam

enum Stat {
	ShipNow,
	ShipMax,
	Accel,
	NewShip,
	NewShield,
	NewBullet,
	NewHomming,
	KillShip,
	KillShield,
	KillBullet,
	KillHomming,
}

static func stat_string(k :Stat) -> String:
	return Stat.keys()[k]

func _to_string() -> String:
	var rtn := ""
	for k in Stat.keys():
		rtn += "%s:%d " %[k, stats[k]]
	return rtn

var color :Color
var name :String
var stats :Dictionary # key string -> int
func _init(co :Color, ship_per_team :int) -> void:
	color = co
	name = NamedColors.get_colorname_by_color(co)
	for k in Stat.keys():
		stats[k] = 0
	set_ship_count_limit(ship_per_team)

func calc_tomake_ship() -> int:
	return get_stat(Stat.ShipMax) - get_stat(Stat.ShipNow)

func inc_ship_count() -> void:
	inc_stat(Stat.ShipNow)

func dec_ship_count() -> void:
	dec_stat(Stat.ShipNow)

func set_ship_count_limit(v :int) -> void:
	set_stat(Stat.ShipMax, v)

func set_stat(k :Stat, v :int) -> void:
	var ks := BattleShooterTeam.stat_string(k)
	stats[ks] =  v

func get_stat(k :Stat) -> int:
	var ks := BattleShooterTeam.stat_string(k)
	return stats[ks]

func inc_stat(k :Stat) -> void:
	var ks := BattleShooterTeam.stat_string(k)
	stats[ks] +=  1

func dec_stat(k :Stat) -> void:
	var ks := BattleShooterTeam.stat_string(k)
	stats[ks] -=  1
