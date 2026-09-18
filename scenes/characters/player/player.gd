class_name Player
extends CharacterBody2D

# movements and physics
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

# jumping
var coyote_timer := CountdownTimer.new(coyote_time)
var jump_buffer_timer := CountdownTimer.new(jump_buffer_time)
var has_dashed_in_air: bool = false


# attacking
@export var combo_reset_time: float = 0.6  # window to chain into next attack after current one ends

var combo_index: int = 0  # 0 = not attacking, 1/2/3 = which attack is active
var combo_buffered: bool = false # did player press attack again during current swing?
var combo_timer := CountdownTimer.new(combo_reset_time)

# Cached per-frame input state — populated once here, read everywhere else
var move_direction: float = 0.0
var has_move_input: bool = false

@onready var state_machine: NodeStateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	_update_input()
	_update_timers(delta)
	

func _update_input():
	# Input: poll exactly once per frame, here
	var buffered_dir: Vector2 = GameInputEvents.movement_input().normalized()
	move_direction = buffered_dir.x
	has_move_input = GameInputEvents.is_movement_input()

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer.start()
		has_dashed_in_air = false
	else:
		coyote_timer.tick(delta)

	if GameInputEvents.is_jump_input():
		jump_buffer_timer.start()
	else:
		jump_buffer_timer.tick(delta)

	if combo_timer.is_active():
		combo_timer.tick(delta)
		if not combo_timer.is_active():
			combo_index = 0

func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + gravity * delta, max_fall_speed)

func is_touching_wall() -> bool:
	return is_on_wall() and move_direction != 0

func check_common_transitions() -> String:
	# Highest priority first — order here IS the priority, documented in one place
	if GameInputEvents.is_attack_input():
		return "attack"
	if jump_buffer_timer.is_active() and coyote_timer.is_active():
		return "jump"
	if Input.is_action_just_pressed("dash") and not has_dashed_in_air:
		return "dash"
	if not is_on_floor():
		return "fall"
	if move_direction != 0:
		return "run"
	return "idle"
