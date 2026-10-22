class_name AttackState
extends NodeState

# True once the current swing's animation has finished and we're just
# waiting out combo_timer's window for a late chained press. Guards
# combo_timer.start() so it fires once per swing instead of being
# re-armed every frame after it expires (which would freeze the state).
var _awaiting_chain: bool = false

# Per swing, indexed by combo_index - 1. Active frames (inclusive) are the
# sword-out frames measured from the Knight sprite sheets; tweak by eye.
@export var active_frames: Array[Vector2i] = [Vector2i(3, 4), Vector2i(1, 2), Vector2i(2, 4)]
@export var swing_damage: Array[int] = [1, 1, 2]
# x is applied in the player's facing direction.
@export var knockback: Vector2 = Vector2(180.0, -120.0)

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
	_update_sword(player)

	if GameInputEvents.is_attack_input():
		player.combo_buffered = true

	if _awaiting_chain:
		# Idle is playing (it loops, so we can't rely on is_playing() here)
		# while we wait out combo_timer for a possible late chain.
		if player.combo_buffered and player.combo_index > 0 and player.combo_index < 3:
			player.combo_index += 1
			player.combo_buffered = false
			_awaiting_chain = false
			player.sprite.play("attack_%d" % player.combo_index)
		return

	if player.sprite.is_playing():
		return

	# Swing just finished: chain immediately if a strike was buffered,
	# otherwise settle into idle and open the combo_reset_time window
	# once to still catch a late press.
	if player.combo_buffered and player.combo_index > 0 and player.combo_index < 3:
		player.combo_index += 1
		player.combo_buffered = false
		player.sprite.play("attack_%d" % player.combo_index)
	else:
		_awaiting_chain = true
		player.sprite.play("idle")
		player.combo_timer.start()

func _on_next_transitions() -> void:
	var player := actor as Player

	if not player.is_on_floor():
		transition.emit("fall")
	elif player.jump_buffer_timer.is_active() and player.coyote_timer.is_active():
		transition.emit("jump")
	elif Input.is_action_just_pressed("dash"):
		transition.emit("dash")
	elif player.move_direction != 0:
		transition.emit("run")
	elif _awaiting_chain and not player.combo_timer.is_active():
		transition.emit("idle")

func _on_exit() -> void:
	var player := actor as Player
	player.combo_index = 0
	player.combo_buffered = false
	player.combo_timer.time_left = 0.0
	_awaiting_chain = false
	player.sword_hitbox.set_active(false)

# The sword is live only on the current swing's active frames. Hitbox hits are
# edge-triggered, so leaving those frames between swings re-arms the next one.
func _update_sword(player: Player) -> void:
	var active := false
	if not _awaiting_chain and player.combo_index > 0:
		var frames := active_frames[player.combo_index - 1]
		active = player.sprite.frame >= frames.x and player.sprite.frame <= frames.y

	if active and not player.sword_hitbox.is_active():
		var facing := player.facing()
		player.sword_hitbox.position.x = absf(player.sword_hitbox.position.x) * facing
		player.sword_hitbox.damage = swing_damage[player.combo_index - 1]
		player.sword_hitbox.knockback = Vector2(knockback.x * facing, knockback.y)

	player.sword_hitbox.set_active(active)
