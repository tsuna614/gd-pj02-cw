class_name CountdownTimer
extends RefCounted

var duration: float = 0.0
var time_left: float = 0.0

func _init(p_duration: float = 0.0) -> void:
	duration = p_duration

func start() -> void:
	time_left = duration

func start_custom(seconds: float) -> void:
	time_left = seconds

func tick(delta: float) -> void:
	time_left = max(time_left - delta, 0.0)

func is_active() -> bool:
	return time_left > 0.0
