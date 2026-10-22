class_name ChickenDeadState
extends NodeState

@export var fade_time: float = 0.5

func _on_enter() -> void:
	var chicken := actor as Chicken
	chicken.hurtbox.enabled = false
	chicken.sprite.play("death")
	var tween := chicken.create_tween()
	tween.tween_property(chicken, "modulate:a", 0.0, fade_time)
	tween.tween_callback(chicken.queue_free)

func _on_physics_process(delta: float) -> void:
	# Keep the knockback slide going while fading out.
	var chicken := actor as Chicken
	chicken.apply_gravity(delta)
	chicken.velocity.x = move_toward(chicken.velocity.x, 0.0, chicken.knockback_friction * delta)
	chicken.move_and_slide()
