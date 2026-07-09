class_name Player
extends CharacterBody2D

@export var speed: float = 220.0
@export var acceleration: float = 1800.0
@export var friction: float = 1600.0
@export var air_acceleration: float = 900.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1400.0
@export var max_fall_speed: float = 900.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var wall_slide_speed: float = 120.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.18

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var has_dashed_in_air: bool = false

@onready var state_machine: NodeStateMachine = $NodeStateMachine
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# shared timers used across states
	if is_on_floor():
		coyote_timer = coyote_time
		has_dashed_in_air = false
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)


func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + gravity * delta, max_fall_speed)


func get_input_dir() -> float:
	return Input.get_axis("move_left", "move_right")


func is_touching_wall() -> bool:
	return is_on_wall() and get_input_dir() != 0
