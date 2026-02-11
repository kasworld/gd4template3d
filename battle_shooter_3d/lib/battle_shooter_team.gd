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
var name_label :Label
var labels :Dictionary # key string -> Label at HUD
var label_settings :LabelSettings

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
	labels[ks].text = str(stats[ks])

func get_stat(k :Stat) -> int:
	var ks := BattleShooterTeam.stat_string(k)
	return stats[ks]

func inc_stat(k :Stat) -> void:
	var ks := BattleShooterTeam.stat_string(k)
	stats[ks] +=  1
	labels[ks].text = str(stats[ks])

func dec_stat(k :Stat) -> void:
	var ks := BattleShooterTeam.stat_string(k)
	stats[ks] -=  1
	labels[ks].text = str(stats[ks])

func _init(ci :int, ball_per_team :int) -> void:
	color = NamedColors.iter_color(ci)
	name = NamedColors.color_to_name[ci][1]

	label_settings = LabelSettings.new()
	label_settings.outline_size = 2
	label_settings.font_color = color
	label_settings.outline_color = color.inverted()
	name_label = make_label(name.to_snake_case())
	for k in Stat.keys():
		stats[k] = 0
		labels[k] = make_label(str(stats[k]))
	set_ship_count_limit(ball_per_team)

func make_label(s :String) -> Label:
	var lb := Label.new()
	lb.text = s
	lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb.label_settings = label_settings
	return lb

static func make_team_list(team_count :int, ball_per_team :int) -> Array[BattleShooterTeam]:
	var in_use_index := {}
	var rtn :Array[BattleShooterTeam] = []
	var color_count := NamedColors.color_list.size()
	for t in team_count:
		var try_color_index :int
		var try_count := 10
		while true:
			try_color_index = randi() % color_count
			if in_use_index.get(try_color_index) == null :
				break
			try_count -= 1
			assert(try_count>=0)
			if try_count < 0:
				print_debug("too many retry")
				break
		in_use_index[try_color_index] = true
		var ct := BattleShooterTeam.new(try_color_index, ball_per_team)
		rtn.append(ct)
#		print("%s %s %s %s" % [t, ct.color_index, ct.color, ct.name])
	return rtn
