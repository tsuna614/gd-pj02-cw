class_name ChickenIdleState
extends NodeState

var _timer := CountdownTimer.new()

func _on_enter() -> void:
	(actor as Chicken).sprite.play("idle")
	_timer.start_custom(randf_range(1.0, 2.0))

func _on_physics_process(delta: float) -> void:
	var chicken := actor as Chicken
	_timer.tick(delta)
	chicken.apply_gravity(delta)
	chicken.velocity.x = 0.0
	chicken.move_and_slide()

func _on_next_transitions() -> void:
	if not _timer.is_active():
		transition.emit("wander")
