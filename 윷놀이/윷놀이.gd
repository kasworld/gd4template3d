extends Node3D
class_name 윷놀이

signal game_ended(game :윷놀이)
signal turn_ended(game :윷놀이, text :String)
signal noti_progress(game :윷놀이, text :String)

const 편당말수 = 4

static var 편인자들 = [
	YutTeam.인자틀.new("빨강색", Color.RED, 4, 1.45),
	YutTeam.인자틀.new("초록색", Color.GREEN, 5, 1.4),
	YutTeam.인자틀.new("파랑색", Color.BLUE, 6, 1.3),
	YutTeam.인자틀.new("노랑색", Color.YELLOW, 8, 1.25),
]

static var 자동진행 :bool = true
static var 눈번호보기 :bool = true
static var 말빠르기 :float = 0.1

var 말이동길_animation := SimpleAnimation.new()

var cabinet_size :Vector3
var yutset := YutSet.new()
var 편들 :Array[YutTeam]
var 이번윷던질편번호 = 0
var 난편들 :Array[YutTeam]
var 말들이동정보g := 말들이동정보.new()

func init(sz :Vector3) -> 윷놀이:
	cabinet_size = sz
	var 판반지름 = min(cabinet_size.x,cabinet_size.y)/2
	var depth = 판반지름/40

	$"말판/원판".init(판반지름, depth, Color(Color.DIM_GRAY, 0.5), 20)
	#$"말판/원판".flip_face(true)
	$"말판/원판".position.z = -depth/2-1
	$"말판/말눈들".init(판반지름*0.95, depth, Color.GRAY)
	$"말판/말눈들".position.z = -depth/2
	$"말판/말눈들".눈번호보기(윷놀이.눈번호보기)

	$"말판/달말통".init(판반지름/4, depth, Color.DARK_BLUE, 64, 0.9).설명달기("달말통", 판반지름/500, Vector3(0,판반지름/3.5,0), Color.BLUE)
	$"말판/달말통".position = Vector3(-판반지름/3,판반지름/3, -depth/2)
	$"말판/난말통".init(판반지름/4, depth, Color.DARK_RED, 64, 0.9).설명달기("난말통", 판반지름/500, Vector3(0,판반지름/3.5,0), Color.RED)
	$"말판/난말통".position = Vector3(판반지름/3,판반지름/3, -depth/2)
	$"말판/이동용말통".init(판반지름*0.03, depth, Color.BLACK )

	말이동길_animation.animation_ended.connect(말이동길_animation_ended)
	init_wheel()
	return self


func init_wheel() -> void:
	var 판반지름 = min(cabinet_size.x,cabinet_size.y)/2
	var symbol_info :Array = []
	for i in YutSet.ArrayToValue:
		var s := YutSet.ValueToString[ YutSet.ArrayToValue[i] ]
		symbol_info.append([Color.BLACK, s ])
	symbol_info.append([Color.BLACK, YutSet.ValueToString[0] ])
	symbol_info.append([Color.BLACK, YutSet.ValueToString[0] ])
	symbol_info.shuffle()
	$Roulette.init(0,판반지름/4,판반지름/40, symbol_info )
	$Roulette.set_acceleration(0.1)
	$Roulette.rotation_stopped.connect(roulette_rotation_stopped)
	$Roulette.show_velvehandle(false)
	$Roulette.show_bartree(false)
	$Roulette.show_spliters(false)
	$Roulette.show_back(false)
	$Roulette.position = Vector3(-판반지름/3, -판반지름/3, 0)


func new_game() -> void:
	var 판반지름 = min(cabinet_size.x,cabinet_size.y)/2
	윷놀이.편인자들.shuffle()
	# 편 가르기
	편들 = []
	난편들 = []
	for n in $"말판/말길들".get_children():
		$"말판/말길들".remove_child(n)
	$"말판/달말통".말모두빼기()
	$"말판/난말통".말모두빼기()
	for ti in 윷놀이.편인자들:
		var t = YutTeam.new()
		var 시작눈 = 말이동길.가능한시작눈목록.pick_random()
		var mirror = randi_range(0,1)==0
		t.init(ti, 윷놀이.편당말수, 판반지름, $"말판/말눈들", 시작눈, mirror)
		편들.append(t)
		$"말판/말길들".add_child(t.길)
		$"말판/달말통".말들넣기(t.말들)
	차례준비하기(0)

func 다음편차례준비하기():
	while true:
		if 난편들.size() == 윷놀이.편인자들.size(): # 모든 편이 다 났다.
			놀이가끝났다()
			return
		이번윷던질편번호 +=1
		이번윷던질편번호 %= 편들.size()
		if 편들[이번윷던질편번호].모든말이났나():
			if 난편들.find(편들[이번윷던질편번호]) == -1:
				난편들.append(편들[이번윷던질편번호])
				편들[이번윷던질편번호].등수쓰기(난편들.size())
			continue
		차례준비하기(이번윷던질편번호)
		break

func 놀이가끝났다() -> void:
	game_ended.emit(self)

func 차례준비하기(편번호 :int):
	turn_ended.emit(self,"%s\n윷던지기" % 편들[편번호])

func 윷던지기() -> void:
	if 난편들.size() == 윷놀이.편인자들.size(): # 모든 편이 다 났다.
		놀이가끝났다()
		return
	var co := 편들[이번윷던질편번호].인자.색
	$Roulette.set_all_text_color(co)
	$Roulette.start_rotation(2*PI)
	말이동길_animation.force_end(false)
	var ani_sec := 0.5
	for i in 편들.size():
		var t = 편들[i]
		if i == 이번윷던질편번호:
			말이동길_animation.start_move("move", t.길, t.길.position, calc_way_show_pos(), ani_sec )
		else:
			말이동길_animation.start_move("move", t.길, t.길.position, calc_way_pos(i), ani_sec )

func _process(_delta: float) -> void:
	말이동길_animation.handle_animation()
	#$Roulette.선택된cell강조상태켜기()

func 말이동길_animation_ended(_st :Node, _ani :Dictionary) -> void:
	pass

func calc_way_pos(i :int) -> Vector3:
	var deg_start = 30.0
	var deg_inc = 360.0 / 편들.size()
	var 판반지름 = min(cabinet_size.x,cabinet_size.y)/2
	var r = 판반지름 * 0.03
	var rd = deg_to_rad( deg_start + i*deg_inc)
	return Vector3(cos(rd)*r, sin(rd)*r, -r*4)

func calc_way_show_pos() -> Vector3:
	var 판반지름 = min(cabinet_size.x,cabinet_size.y)/2
	var r = 판반지름 * 0.03
	return Vector3(0,0,0)

func roulette_rotation_stopped(_rl :Roulette) -> void:
	yutset.set_by_string($Roulette.선택된cell얻기().글내용얻기())
	말이동하기()

func 말이동하기() -> void:
	var 윷던진편 = 편들[이번윷던질편번호]
	var m = 윷던진편.쓸말고르기(yutset)
	말들이동정보g = 윷던진편.말이동정보만들기(yutset, m)
	말들이동정보g.다음편으로넘어가나 = (not yutset.can_more_turn) and 말들이동정보g.잡힐말들.is_empty()
	if not 말들이동정보g.이동성공:
		진행사항기록하기( "%s %s 이동할 말이 없습니다.\n" % [윷던진편 , yutset ] )
		이동애니메이션후처리하기()
		return
	var 이동좌표들 = $"말판/말눈들".눈번호들을좌표로(말들이동정보g.이동과정눈번호들)
	if 말들이동정보g.새로달말 != null:
		이동좌표들.push_front(윷던진편.길.놓을길시작 )
	if not 말들이동정보g.놓을말로돌아갈말들.is_empty():
		진행사항기록하기( "    %s 놓을말로되돌아갔습니다.\n" % [말들이동정보g.놓을말로돌아갈말들 ] )
		이동좌표들.push_back(윷던진편.길.놓을길시작 )
	if not 말들이동정보g.날말들.is_empty():
		진행사항기록하기( "    %s 났습니다.\n" % [말들이동정보g.날말들 ] )
		이동좌표들.push_back(윷던진편.길.나는길끝 )
	if not 말들이동정보g.잡힐말들.is_empty() :
		진행사항기록하기( "    %s 을 잡아 한번더 던집니다.\n" % [ 말들이동정보g.잡힐말들 ] )
	for mm in 말들이동정보g.이동할말들:
		mm.get_parent().remove_child(mm)
		mm.이동말로만들기()
		$"말판/이동용말통".말넣기(mm)
	# 애니메이션 시작
	$"말판/말이동AnimationPlayer".stop()
	var 말이동 = $"말판/말이동AnimationPlayer".get_animation("말이동")
	말이동.length = 말빠르기 * 이동좌표들.size()
	for i in 말이동.track_get_key_count(0) :
		말이동.track_remove_key(0,0)
	for i in 이동좌표들.size():
		말이동.track_insert_key(0, 말빠르기 * i, 이동좌표들[i])
	$"말판/이동용말통".visible = true
	$"말판/말이동AnimationPlayer".play("말이동")

func 이동애니메이션후처리하기() -> void:
	$"말판/이동용말통".visible = false
	var 이동한말들 = $"말판/이동용말통".말모두빼기()
	if 말들이동정보g.도착눈 != null :
		말들이동정보g.도착눈.말놓기(이동한말들)
	if 말들이동정보g.놓을말로돌아갈말들.size() != 0:
		for m in 말들이동정보g.놓을말로돌아갈말들:
			m.달말로만들기()
		$"말판/달말통".말들넣기(말들이동정보g.놓을말로돌아갈말들)
	if 말들이동정보g.날말들.size() != 0:
		for m in 말들이동정보g.날말들:
			m.난말로만들기()
		$"말판/난말통".말들넣기(말들이동정보g.날말들)
	if 말들이동정보g.잡힐말들.size() != 0 :
		for m in 말들이동정보g.잡힐말들:
			m.달말로만들기()
		$"말판/달말통".말들넣기(말들이동정보g.잡힐말들)

	if 말들이동정보g.다음편으로넘어가나:
		다음편차례준비하기()
	if 윷놀이.자동진행:
		윷던지기.call_deferred()


func 진행사항기록하기(s :String) -> void:
	noti_progress.emit(self, s)

func _on_말이동animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "말이동":
		이동애니메이션후처리하기()

func _on_시작animation_player_animation_finished(anim_name: StringName) -> void:
	if 윷놀이.자동진행:
		윷던지기()
