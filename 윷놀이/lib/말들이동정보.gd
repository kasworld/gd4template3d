class_name 말들이동정보

var 이동과정눈번호들 :Array[int]
var 도착눈 :눈 # 말인 난 경우 null
var 새로달말 :말
var 이동할말들 :Array[말]
var 잡힐말들 :Array[말]
var 놓을말로돌아갈말들 :Array[말]
var 날말들 :Array[말]

var 이동성공 :bool
var 다음편으로넘어가나:bool

func _init() -> void:
	다음편으로넘어가나 = true

func _to_string() -> String:
	return "말들이동정보[이동성공:%s 다음편으로넘어가나:%s 이동과정눈번호들:%s 도착눈:%s 새로달말:%s 이동할말들:%s 잡힐말들:%s 놓을말로돌아갈말들:%s 날말들:%s]" % [
		이동성공, 다음편으로넘어가나, 이동과정눈번호들, 도착눈, 새로달말, 이동할말들, 잡힐말들, 놓을말로돌아갈말들, 날말들]
