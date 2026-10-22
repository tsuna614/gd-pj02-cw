class_name ChickenHurtState
extends NodeState

# Knockback velocity, flash, and stun_timer are set by Chicken._on_hurtbox_hit
# before transitioning here.

func _on_enter() -> void:
	(actor as Chicken).sprite.play("hurt")

func _on_physics_process(delta: float) -> void:
	var chicken := actor as Chicken
	chicken.stun_timer.tick(delta)
	chicken.apply_gravity(delta)
	chicken.velocity.x = move_toward(chicken.velocity.x, 0.0, chicken.knockback_friction * delta)
	chicken.move_and_slide()

func _on_next_transitions() -> void:
	var chicken := actor as Chicken
	if not chicken.stun_timer.is_active() and chicken.is_on_floor():
		transition.emit("wander")
