class_name JumpState
extends NodeState


func _on_enter() -> void:
	var player := actor as Player
	player.velocity.y = player.jump_velocity
	player.coyote_timer.time_left = 0.0
	player.jump_buffer_timer.time_left = 0.0
	player.sprite.play("jump")

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

	if player.is_touching_wall() and not player.is_on_floor():
		transition.emit("wallslide")
	elif Input.is_action_just_pressed("dash"):
		transition.emit("dash")
	elif player.velocity.y > 0.0:
		transition.emit("fall")
	elif player.velocity.y == 0.0:
		transition.emit("idle")
