class_name Chicken
extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 1400.0
@export var max_fall_speed: float = 900.0

var facing: float = 1.0  # 1 = right, -1 = left

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ledge_ray: RayCast2D = $LedgeRay
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: Health = $Health


func _ready() -> void:
	set_facing(1.0 if randf() < 0.5 else -1.0)

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
