class_name AttackState
extends NodeState

func _on_enter() -> void:
	(actor as Player).sprite.play("attack_1")

func _on_physics_process(delta: float) -> void:
	var player := actor as Player
	player.apply_gravity(delta)
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	player.move_and_slide()

func _on_next_transitions() -> void:
	var player := actor as Player

	if not player.is_on_floor():
		transition.emit("fall")
	elif player.jump_buffer_timer.is_active() and player.coyote_timer.is_active():
		transition.emit("jump")
	elif player.move_direction != 0:
		transition.emit("run")
	elif Input.is_action_just_pressed("dash"):
		transition.emit("dash")
