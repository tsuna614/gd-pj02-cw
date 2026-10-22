class_name FallState
extends NodeState


func _on_enter() -> void:
	# No dedicated fall animation yet: hold the last frame of the jump.
	var sprite := (actor as Player).sprite
	sprite.play("jump")
	sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 1
	sprite.pause()

func _on_physics_process(delta: float) -> void:
	var player := actor as Player
	player.apply_gravity(delta)

	var dir := player.move_direction
	player.velocity.x = move_toward(player.velocity.x, dir * player.speed, player.air_acceleration * delta)
	if dir != 0:
		player.sprite.flip_h = dir < 0

	player.move_and_slide()

func _on_next_transitions() -> void:
	var player := actor as Player

	if player.jump_buffer_timer.is_active() and player.coyote_timer.is_active():
		transition.emit("jump")
	elif player.is_on_floor():
		if player.move_direction != 0:
			transition.emit("run")
		else:
			transition.emit("idle")
	elif player.is_touching_wall():
		transition.emit("wallslide")
	elif Input.is_action_just_pressed("dash"):
		transition.emit("dash")
