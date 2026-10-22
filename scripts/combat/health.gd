class_name Health
extends Node

signal damaged(amount: int, current_hp: int)
signal died

@export var max_hp: int = 3

var current_hp: int

func _ready() -> void:
	current_hp = max_hp

func take_damage(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	current_hp = max(current_hp - amount, 0)
	damaged.emit(amount, current_hp)
	if current_hp == 0:
		died.emit()

func is_dead() -> bool:
	return current_hp <= 0
