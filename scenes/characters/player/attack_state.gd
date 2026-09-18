class_name AttackState
extends NodeState

# True once the current swing's animation has finished and we're just
# waiting out combo_timer's window for a late chained press. Guards
# combo_timer.start() so it fires once per swing instead of being
# re-armed every frame after it expires (which would freeze the state).
var _awaiting_chain: bool = false

func _on_enter() -> void:
	var player := actor as Player
	player.combo_index = 1
	player.combo_buffered = false
	player.combo_timer.time_left = 0.0
	_awaiting_chain = false
	player.sprite.play("attack_1")

func _on_physics_process(delta: float) -> void:
	var player := actor as Player
	player.apply_gravity(delta)
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	player.move_and_slide()

	if GameInputEvents.is_attack_input():
		player.combo_buffered = true

	if player.sprite.is_playing():
		return

	# Swing finished: chain immediately if a strike was buffered, otherwise
	# open the combo_reset_time window once to still catch a late press.
	if player.combo_buffered and player.combo_index > 0 and player.combo_index < 3:
		player.combo_index += 1
		player.combo_buffered = false
		player.combo_timer.time_left = 0.0
		_awaiting_chain = false
		player.sprite.play("attack_%d" % player.combo_index)
	elif not _awaiting_chain:
		_awaiting_chain = true
		# player.sprite.play("idle")
		player.combo_timer.start()

func _on_next_transitions() -> void:
	var player := actor as Player

	if not player.is_on_floor():
		transition.emit("fall")
	elif player.jump_buffer_timer.is_active() and player.coyote_timer.is_active():
		transition.emit("jump")
	elif Input.is_action_just_pressed("dash"):
		transition.emit("dash")
	elif _awaiting_chain and not player.combo_timer.is_active():
		transition.emit("idle")

func _on_exit() -> void:
	var player := actor as Player
	player.combo_index = 0
	player.combo_buffered = false
	player.combo_timer.time_left = 0.0
	_awaiting_chain = false
