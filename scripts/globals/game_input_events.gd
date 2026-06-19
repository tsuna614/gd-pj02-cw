class_name GameInputEvents

#static var direction: Vector2

static var input_buffer = [Vector2.ZERO]

static func movement_input() -> Vector2:
	#if Input.is_action_pressed("walk_up"):
		#direction = Vector2.UP
	#elif Input.is_action_pressed("walk_down"):
		#direction = Vector2.DOWN
	#elif Input.is_action_pressed("walk_left"):
		#direction = Vector2.LEFT
	#elif Input.is_action_pressed("walk_right"):
		#direction = Vector2.RIGHT
	#else:
		#direction = Vector2.ZERO
		
	if Input.is_action_just_pressed("walk_right"):
		input_buffer.append(Vector2.RIGHT)
	if Input.is_action_just_pressed("walk_left"):
		input_buffer.append(Vector2.LEFT)
	if Input.is_action_just_pressed("walk_up"):
		input_buffer.append(Vector2.UP)
	if Input.is_action_just_pressed("walk_down"):
		input_buffer.append(Vector2.DOWN)
	if Input.is_action_just_released("walk_right"):
		input_buffer.erase(Vector2.RIGHT)
	if Input.is_action_just_released("walk_left"):
		input_buffer.erase(Vector2.LEFT)
	if Input.is_action_just_released("walk_up"):
		input_buffer.erase(Vector2.UP)
	if Input.is_action_just_released("walk_down"):
		input_buffer.erase(Vector2.DOWN)
		
	return input_buffer.back()

static func is_movement_input() -> bool:
	if input_buffer.back() == Vector2.ZERO:
		return false
	else:
		return true


static func is_sprint_input() -> bool:
	if Input.is_action_pressed("sprint"):
		return true
	else:
		return false


static func use_tool() -> bool:
	var use_tool_value: bool = Input.is_action_just_pressed("hit")
	
	return use_tool_value
