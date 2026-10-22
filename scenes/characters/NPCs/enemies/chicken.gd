class_name Chicken
extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 1400.0
@export var max_fall_speed: float = 900.0
@export var knockback_friction: float = 900.0
@export var hurt_stun_time: float = 0.3

var facing: float = 1.0  # 1 = right, -1 = left
# Restarted on every hit; Hurt waits for it, so a hit during Hurt extends the stun.
var stun_timer := CountdownTimer.new()

var _flash_tween: Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ledge_ray: RayCast2D = $LedgeRay
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health
@onready var state_machine: NodeStateMachine = $StateMachine


func _ready() -> void:
	set_facing(1.0 if randf() < 0.5 else -1.0)
	hurtbox.hit.connect(_on_hurtbox_hit)

# Hurtbox hits are once per sword activation, so the Hurtbox stays enabled
# during Hurt; disabling it would swallow the next combo swing.
func _on_hurtbox_hit(hitbox: Hitbox) -> void:
	if health.is_dead():
		return
	health.take_damage(hitbox.damage)
	velocity = hitbox.knockback
	if hitbox.knockback.x != 0.0:
		set_facing(-signf(hitbox.knockback.x))  # face the attacker
	flash()
	stun_timer.start_custom(hurt_stun_time)
	state_machine.transition_to("dead" if health.is_dead() else "hurt")

func flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
	# self_modulate, so the placeholder tint on modulate is left alone.
	sprite.self_modulate = Color(3, 3, 3)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.15)

func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + gravity * delta, max_fall_speed)

func set_facing(dir: float) -> void:
	facing = dir
	sprite.flip_h = dir < 0
	# Keep the ledge probe at the leading edge.
	ledge_ray.position.x = absf(ledge_ray.position.x) * dir
	ledge_ray.force_raycast_update()

# Blocked by a wall, or about to walk off a ledge.
func should_turn() -> bool:
	return is_on_wall() or (is_on_floor() and not ledge_ray.is_colliding())
