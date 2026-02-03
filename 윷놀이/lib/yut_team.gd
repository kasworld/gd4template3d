class_name YutTeam

class 인자틀:
	var 이름 :String
	var 색 :Color
	var 모양 :int
	var 크기보정 :float
	func _init(a,b,c,d) -> void:
		이름 = a
		색 = b
		모양 = c
		크기보정 = d

var 인자 :인자틀
var 눈들 :말눈들
var 길 :말이동길
var 말들 :Array[말] = []
var 등수 :int

func _to_string() -> String:
	return "%s편" % [인자.이름]

func debug_str() -> String:
	var rtn = "%s" % self
	for m in 말들:
		rtn += " " + m.debug_str()
	return rtn

func 상태검사() -> String:
	var rtn = ""
	for m in 말들:
		var s = 말상태검사(m)
		if s != "":
			rtn += s + " "
	return rtn

func 말상태검사(m :말) -> String:
	if m.달말인가() or m.난말인가():
		if not m.지나온눈번호들.is_empty():
			return "말의 지나온눈번호들이 비어있지않다. %s" % [m.debug_str() ]
		else:
			return ""
	var 속한눈 = 눈들.눈얻기(m.마지막눈번호())
	var rtn = 속한눈.말보기()
	if not 속한눈.말이있나(m):
		return "말이 눈에 속하지 않다. %s %s" % [m.debug_str(), 속한눈.debug_str() ]
	elif rtn.is_empty() :
		return "말이 속한 눈이 비어 있다. %s %s" % [m.debug_str(), 속한눈.debug_str() ]
	return "뭔가이상함 %s %s" % [m.debug_str(), 속한눈.debug_str() ]

func 등수쓰기(n :int):
	등수 = n

func 등수얻기() -> int:
	return 등수

func init(편정보 :인자틀, 말수 :int, 크기:float, es :말눈들, 시작눈 :int, mirror :bool = false) -> YutTeam:
	인자 = 편정보
	눈들 = es
	길 = preload("res://윷놀이/말이동길.tscn").instantiate().init( 크기/200, 인자.색, es.눈들, 시작눈, mirror)
	var r = 크기/30
	for i in range(0,말수):
		var m = preload("res://윷놀이/말.tscn").instantiate().init(self, r,r/3, i+1)
		말들.append(m)
	return self

func 난말수얻기() -> int:
	var rtn :int = 0
	for n in 말들:
		if n.난말인가():
			rtn +=1
	return rtn

func 모든말이났나() -> bool:
	return 난말수얻기() == 말들.size()

# 이동 주체로 사용 불가
func 업힌말인가(m :말)->bool:
	var ms = 업은말들얻기(m)
	return m.판위말인가() and ms[0] != m

func 업은말들얻기(m :말)->Array[말]:
	var 속한눈 = 눈들.눈얻기(m.마지막눈번호())
	var rtn = 속한눈.말보기()
	if not 속한눈.말이있나(m):
		print_debug("문제:말이 눈에 속하지 않다. %s %s" %	[
			m.debug_str(), 속한눈.debug_str() ])
	elif rtn.is_empty() :
		print_debug("문제:말이 속한 눈이 비어 있다. %s %s" % [
			m.debug_str(), 속한눈.debug_str() ])
	return rtn

func 쓸말고르기(yutset :YutSet)->말:
	var 섞은말 = 말들.duplicate()
	섞은말.shuffle()
	for m in 섞은말:
		if m.난말인가():
			continue
		if m.달말인가():
			if yutset.result_value <= 0:
				continue
			return m
		if 업힌말인가(m):
			continue
		return m
	# 쓸말이 없음
	return null

func 말이동정보만들기(yutset :YutSet, m :말)->말들이동정보:
	if m == null :
		return 말들이동정보.new()
	if m.난말인가() :
		return 말들이동정보.new()
	if m.달말인가() and yutset.result_value > 0:
		return 새로말달정보만들기(yutset, m)
	if 업힌말인가(m):
		return 말들이동정보.new()
	return 판위의말이동할정보만들기(yutset, m)

func 새로말달정보만들기(yutset :YutSet, m :말)->말들이동정보:
	var 결과 = 말들이동정보.new()
	결과.이동과정눈번호들 = 길.말이동과정찾기(-1,yutset.result_value)
	for i in 결과.이동과정눈번호들:
		m.지나온눈번호들.append(i)
	결과.도착눈 = 눈들.눈얻기(결과.이동과정눈번호들[-1])
	결과.잡힐말들 = 결과.도착눈.말잡기시도([m])
	결과.새로달말 = m
	결과.이동할말들.append(m)
	결과.이동성공 = true
	return 결과

func 판위의말이동할정보만들기(yutset :YutSet, m :말)->말들이동정보:
	var 결과 = 말들이동정보.new()
	결과.이동할말들 = 업은말들얻기(m)
	if yutset.result_value < 0: # 뒷도개걸 처리
		if m.지나온눈번호들.size() <= -yutset.result_value: #판에서 빼서 놓을 말로 돌아간다.
			for i in m.지나온눈번호들:
				결과.이동과정눈번호들.append(i)
			결과.이동과정눈번호들.reverse()
			결과.놓을말로돌아갈말들 = 결과.이동할말들
			결과.이동성공 = true
			return 결과
		for i in range(yutset.result_value,0): # 업은말의 첫말의 지나온눈번호들에서 빼면서 뒤로 이동한다.
			결과.이동과정눈번호들.append(m.지나온눈번호들.pop_back())
		결과.이동과정눈번호들.append(m.마지막눈번호())
		결과.도착눈 = 눈들.눈얻기(m.마지막눈번호())
		결과.잡힐말들 = 결과.도착눈.말잡기시도(결과.이동할말들)
		결과.이동성공 = true
		return 결과

	# 앞으로 가기
	var 기존위치눈번호 = m.마지막눈번호()
	결과.이동과정눈번호들 = 길.말이동과정찾기(m.마지막눈번호(),yutset.result_value)
	for i in 결과.이동과정눈번호들: # 말에 지나가는 눈들 추가
		m.지나온눈번호들.append(i)
	결과.이동과정눈번호들.push_front(기존위치눈번호)
	if 결과.이동과정눈번호들[-1] == 길.종점눈번호(): # 말이 났다.
		결과.날말들 = 결과.이동할말들
		결과.이동성공 = true
		return 결과
	결과.도착눈 = 눈들.눈얻기(결과.이동과정눈번호들[-1])
	결과.잡힐말들 = 결과.도착눈.말잡기시도(결과.이동할말들)
	결과.이동성공 = true
	return 결과
