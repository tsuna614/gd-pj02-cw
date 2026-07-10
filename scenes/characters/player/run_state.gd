class_name RunState
extends NodeState


func _on_enter() -> void:
	(actor as Player).sprite.play("run")

func _on_physics_process(delta: float) -> void:
	var player := actor as Player
	player.apply_gravity(delta)

	var dir := player.get_input_dir()
	player.velocity.x = move_toward(player.velocity.x, dir * player.speed, player.acceleration * delta)
	player.sprite.flip_h = dir < 0

	player.move_and_slide()

func _on_next_transitions() -> void:
	var player := actor as Player

	if not player.is_on_floor():
		transition.emit("fall")
	elif player.jump_buffer_timer > 0.0 and player.coyote_timer > 0.0:
		transition.emit("jump")
	elif player.get_input_dir() == 0:
		transition.emit("idle")
	elif Input.is_action_just_pressed("dash"):
		transition.emit("dash")
