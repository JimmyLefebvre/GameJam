extends CharacterBody2D
class_name player_controller

@export var speed := 10.0
@export var jump_power := 10.0

var speed_multiplier := 30.0
var jump_multiplier := -30.0

# Gravité simplifiée (tu peux tweak facilement)
var gravity := 800.0
var fall_gravity := 1250.0
var fast_fall_gravity := 2000.0
var wall_gravity := 25.0

var direction := 0

# Timers
var input_buffer : Timer
var coyote_timer : Timer
var coyote_jump_available := true

const INPUT_BUFFER_PATIENCE = 0.1
const COYOTE_TIME = 0.1


func _ready() -> void:
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)

	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)


func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	var jump_attempted := Input.is_action_just_pressed("jump")

	# Jump logic
	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available:
			velocity.y = jump_power * jump_multiplier
			coyote_jump_available = false

		elif is_on_wall() and direction != 0:
			velocity.y = jump_power * jump_multiplier
			velocity.x = -sign(direction) * speed * speed_multiplier

		elif jump_attempted:
			input_buffer.start()

	# Jump cut (meilleur feeling)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.25

	# Gravity + coyote
	if is_on_floor():
		coyote_jump_available = true
		coyote_timer.stop()
	else:
		if coyote_jump_available and coyote_timer.is_stopped():
			coyote_timer.start()

		velocity.y += calculate_gravity(direction) * delta

	# Mouvement horizontal
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()


func calculate_gravity(input_dir: float = 0) -> float:
	if Input.is_action_pressed("fast_fall"):
		return fast_fall_gravity

	if is_on_wall_only() and velocity.y > 0 and input_dir != 0:
		return wall_gravity

	return gravity if velocity.y < 0 else fall_gravity


func coyote_timeout() -> void:
	coyote_jump_available = false
