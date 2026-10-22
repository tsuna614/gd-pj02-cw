class_name ChickenWanderState
extends NodeState

var _timer := CountdownTimer.new()

func _on_enter() -> void:
	(actor as Chicken).sprite.play("walk")
	_timer.start_custom(randf_range(2.0, 4.0))

func _on_physics_process(delta: float) -> void:
	var chicken := actor as Chicken
	_timer.tick(delta)
	chicken.apply_gravity(delta)
	chicken.velocity.x = chicken.facing * chicken.speed
	chicken.move_and_slide()

	if chicken.should_turn():
		chicken.set_facing(-chicken.facing)

func _on_next_transitions() -> void:
	if not _timer.is_active():
		transition.emit("idle")
