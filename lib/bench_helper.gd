class_name BenchHelper

var count :int
var start_time :float
var dur_sec :float
var val_per_sec :float

func _init(count_init ) -> void:
	count = int(count_init)
	start_time = Time.get_unix_time_from_system()

func end(new_count :int = count) -> void:
	count = new_count
	dur_sec = Time.get_unix_time_from_system() - start_time
	val_per_sec = count / dur_sec

func get_result() -> String:
	return "count %d, %f sec, %f count/sec" % [count , dur_sec, val_per_sec ]
