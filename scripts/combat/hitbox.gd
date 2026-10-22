class_name Hitbox
extends Area2D

# Deals damage to overlapping Hurtboxes. Starts inactive; the owner turns it
# on only for an attack's active frames. Activation is edge-triggered: a
# Hurtbox is hit when the shapes are enabled while overlapping it, so to hit
# again (e.g. the next combo swing) deactivate and reactivate.

@export var damage: int = 1
@export var knockback: Vector2 = Vector2.ZERO

var _active: bool = false
# Hurtboxes already hit during this activation, so one swing hits once.
var _hit_targets: Array[Hurtbox] = []

func _ready() -> void:
	# Only Hurtboxes need to detect overlaps; the Hitbox just has to be visible to them.
	monitoring = false
	_set_shapes_disabled(true)

func set_active(active: bool) -> void:
	if active == _active:
		return
	_active = active
	if active:
		_hit_targets.clear()
	_set_shapes_disabled(not active)

func is_active() -> bool:
	return _active

# Returns false if this Hurtbox was already hit during the current activation.
func register_hit(hurtbox: Hurtbox) -> bool:
	if hurtbox in _hit_targets:
		return false
	_hit_targets.append(hurtbox)
	return true

func _set_shapes_disabled(disabled: bool) -> void:
	# Deferred: shapes can't be toggled during physics callbacks (area/body signals).
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", disabled)
