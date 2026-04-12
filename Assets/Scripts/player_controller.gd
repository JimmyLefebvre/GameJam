extends CharacterBody2D
class_name player_controller

#region Variables
@export var speed: float = 4.8
@export var jump_power: float = 8.0

var speed_multiplier: float = 30.0
var jump_multiplier: float = -30.0

var gravity: float = 800.0
var fast_fall_gravity: float = 1000.0
var wall_gravity: float = 100.0

var max_fall_speed: float = 350.0
var max_fast_fall_speed: float = 600.0

var apex_threshold: float = 20.0
var apex_gravity_scale: float = 0.5

var acceleration: float = 1800.0

var wall_jump_x_force: float = 1.0
var wall_jump_lock_duration: float = 0.2
var wall_jump_lock_timer: float = 0.0
var is_wall_jumping: bool = false

# Temps minimum accroché au mur avant de pouvoir wall jump
var wall_grip_required: float = 0.08   # en secondes — tweake cette valeur
var wall_grip_timer: float = 0.0       # temps passé contre le mur
var wall_jump_ready: bool = false       # wall jump déverrouillé ?

var direction: float = 0.0
var wall_side: float = 0.0

var input_buffer: Timer
var coyote_timer: Timer
var coyote_jump_available: bool = true

const INPUT_BUFFER_PATIENCE: float = 0.1
const COYOTE_TIME: float = 0.1
#endregion

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

	if is_on_wall_only():
		wall_side = get_wall_normal().x
		# Accumule le temps de grip
		wall_grip_timer += delta
		if wall_grip_timer >= wall_grip_required:
			wall_jump_ready = true
	else:
		# Quitte le mur → reset du grip
		wall_grip_timer = 0.0
		wall_jump_ready = false

	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available:
			velocity.y = jump_power * jump_multiplier
			coyote_jump_available = false
			is_wall_jumping = false
		elif is_on_wall_only() and wall_jump_ready:
			velocity.y = jump_power * jump_multiplier
			velocity.x = wall_side * speed * speed_multiplier * wall_jump_x_force
			wall_jump_lock_timer = wall_jump_lock_duration
			is_wall_jumping = true
			wall_grip_timer = 0.0
			wall_jump_ready = false
		elif jump_attempted:
			input_buffer.start()

	if Input.is_action_just_released("jump") and velocity.y < 0 and not is_wall_jumping:
		velocity.y *= 0.4

	if is_on_floor():
		coyote_jump_available = true
		coyote_timer.stop()
		wall_jump_lock_timer = 0.0
		is_wall_jumping = false
		wall_grip_timer = 0.0
		wall_jump_ready = false
	else:
		if coyote_jump_available and coyote_timer.is_stopped():
			coyote_timer.start()
		velocity.y += calculate_gravity(direction) * delta
		if Input.is_action_pressed("fast_fall"):
			velocity.y = min(velocity.y, max_fast_fall_speed)
		else:
			velocity.y = min(velocity.y, max_fall_speed)

	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer -= delta
		if wall_jump_lock_timer <= 0.0:
			is_wall_jumping = false
	else:
		var target_x := direction * speed * speed_multiplier
		velocity.x = move_toward(velocity.x, target_x, acceleration * delta)

	move_and_slide()

func calculate_gravity(input_dir: float = 0) -> float:
	if is_wall_jumping:
		return gravity
	if Input.is_action_pressed("fast_fall"):
		return fast_fall_gravity
	if is_on_wall_only() and velocity.y > 0 and input_dir != 0:
		return wall_gravity
	if not is_on_floor() and abs(velocity.y) < apex_threshold:
		return gravity * apex_gravity_scale
	return gravity

func coyote_timeout() -> void:
	coyote_jump_available = false
