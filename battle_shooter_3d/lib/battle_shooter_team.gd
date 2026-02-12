class_name BattleShooterTeam

enum Stat {
	SHIP_NOW,
	SHIP_MAX,
	ACCEL,
	NEW_SHIP,
	NEW_SHIELD,
	NEW_BULLET,
	NEW_HOMMING,
	KILL_SHIP,
	KILL_SHIELD,
	KILL_BULLET,
	KILL_HOMMING,
}

static func stat_string(k :Stat) -> String:
	return Stat.keys()[k]


var color :Color
var name :String
var stats :Dictionary # key string -> int
func _init(co :Color, ship_per_team :int) -> void:
	color = co
	name = NamedColors.get_colorname_by_color(co)
	for k in Stat.keys():
		stats[k] = 0
	set_ship_count_limit(ship_per_team)

func calc_tomake_ball() -> int:
	return get_stat(Stat.SHIP_MAX) - get_stat(Stat.SHIP_NOW)

func inc_ship_count() -> void:
	inc_stat(Stat.SHIP_NOW)

func dec_ship_count() -> void:
	dec_stat(Stat.SHIP_NOW)

func set_ship_count_limit(v :int) -> void:
	set_stat(Stat.SHIP_MAX, v)

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
