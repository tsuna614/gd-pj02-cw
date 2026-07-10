class_name GameInputEvents

static var input_buffer: Array[Vector2] = [Vector2.ZERO]


static func movement_input() -> Vector2:
	if Input.is_action_just_pressed("move_right") and not input_buffer.has(Vector2.RIGHT):
		input_buffer.append(Vector2.RIGHT)
	if Input.is_action_just_pressed("move_left") and not input_buffer.has(Vector2.LEFT):
		input_buffer.append(Vector2.LEFT)

	if Input.is_action_just_released("move_right"):
		input_buffer.erase(Vector2.RIGHT)
	if Input.is_action_just_released("move_left"):
		input_buffer.erase(Vector2.LEFT)

	return input_buffer.back()


static func is_movement_input() -> bool:
	return input_buffer.back() != Vector2.ZERO


static func is_sprint_input() -> bool:
	return Input.is_action_pressed("sprint")


static func use_tool() -> bool:
	return Input.is_action_just_pressed("hit")


# Call this on respawn / scene reload / pause-exit to avoid stuck input state
static func reset() -> void:
	input_buffer = [Vector2.ZERO]
