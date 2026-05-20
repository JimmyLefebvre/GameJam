extends CharacterBody2D
class_name PlayerController

#region Exports
@export_group("Vie")
@export var max_health: float = 3.0

var health: float = max_health

signal damaged(amount: float)
signal died

@export_group("Mouvement horizontal")
@export var speed: float = 4.8
@export var acceleration: float = 1800.0

@export_group("Saut")
@export var jump_power: float = 8.0
@export var jump_cut_multiplier: float = 0.4

@export_group("Gravité")
@export var gravity: float = 800.0
@export var fast_fall_gravity: float = 1000.0
@export var wall_gravity: float = 100.0
@export var apex_threshold: float = 20.0
@export var apex_gravity_scale: float = 0.5
@export var max_fall_speed: float = 400.0
@export var max_fast_fall_speed: float = 600.0

@export_group("Wall jump")
@export var wall_jump_x_force: float = 1.0
@export var wall_jump_lock_duration: float = 0.2
@export var wall_grip_required: float = 0.08

@export_group("Dash")
@export var dash_speed: float = 350.0
@export var dash_duration: float = 0.3
@export var dash_gravity_scale: float = 0.05
@export var dash_cooldown: float = 0.6
@export var dash_momentum_duration: float = 0.05
@export var dash_end_momentum: float = 0.6  # remplace la constante DASH_END_MOMENTUM
#endregion

#region Constantes internes
const SPEED_MULTIPLIER: float = 30.0
const JUMP_MULTIPLIER: float = -30.0
const INPUT_BUFFER_PATIENCE: float = 0.1
const COYOTE_TIME: float = 0.1
#endregion

#region État interne
var _direction: float = 0.0
var _vertical_input: float = 0.0
var _wall_side: float = 0.0
var _last_facing_dir: float = 1.0
var is_dead := false

# Wall jump
var _wall_grip_timer: float = 0.0
var _wall_jump_lock_timer: float = 0.0
var _wall_jump_ready: bool = false
var _is_wall_jumping: bool = false

# Dash
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _dash_available: bool = true
var _is_dashing: bool = false
var _dash_momentum_timer: float = 0.0

# Coyote / buffer
var _coyote_jump_available: bool = true
var _input_buffer: Timer
var _coyote_timer: Timer
#endregion

func _ready() -> void:
	_input_buffer = _make_timer(INPUT_BUFFER_PATIENCE)
	_coyote_timer = _make_timer(COYOTE_TIME)
	_coyote_timer.timeout.connect(_on_coyote_timeout)
	$HurtBox.damaged.connect(_on_damaged)
	died.connect(_on_died)

func _physics_process(delta: float) -> void:
	_direction = Input.get_axis("move_left", "move_right")
	_vertical_input = Input.get_axis("move_up", "fast_fall")

	if _dash_cooldown_timer > 0.0:
		_dash_cooldown_timer -= delta

	_update_wall_state(delta)
	_update_floor_state()

	if _handle_dash(delta):
		return

	_handle_jump()
	_handle_gravity(delta)
	_handle_horizontal(delta)

	move_and_slide()

#region Handlers principaux

func _handle_dash(delta: float) -> bool:
	if Input.is_action_just_pressed("dash") and _dash_available and not _is_dashing and _dash_cooldown_timer <= 0.0:
		_start_dash()

	if not _is_dashing:
		return false

	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_end_dash()
		return false

	velocity = _dash_direction * dash_speed
	if not is_on_floor():
		velocity.y += gravity * dash_gravity_scale * delta
	move_and_slide()
	return true

func _handle_jump() -> void:
	var jump_attempted := Input.is_action_just_pressed("jump")

	if jump_attempted or _input_buffer.time_left > 0:
		if _coyote_jump_available:
			_do_jump()
		elif is_on_wall_only() and _wall_jump_ready:
			_do_wall_jump()
		elif jump_attempted:
			_input_buffer.start()

	if Input.is_action_just_released("jump") and velocity.y < 0 and not _is_wall_jumping:
		velocity.y *= jump_cut_multiplier

func _handle_gravity(delta: float) -> void:
	if is_on_floor():
		return

	if _dash_momentum_timer > 0.0:
		return  # préserve velocity.y du dash

	velocity.y += _calculate_gravity() * delta
	var fall_cap := max_fast_fall_speed if Input.is_action_pressed("fast_fall") else max_fall_speed
	velocity.y = min(velocity.y, fall_cap)

func _handle_horizontal(delta: float) -> void:
	if _wall_jump_lock_timer > 0.0:
		_wall_jump_lock_timer -= delta
		if _wall_jump_lock_timer <= 0.0:
			_is_wall_jumping = false
		return

	if _dash_momentum_timer > 0.0:
		_dash_momentum_timer -= delta
		return  # préserve velocity.x du dash

	var target_x := _direction * speed * SPEED_MULTIPLIER
	velocity.x = move_toward(velocity.x, target_x, acceleration * delta)
	if _direction != 0.0:
		_last_facing_dir = _direction

#endregion

#region Actions de saut / dash

func _do_jump() -> void:
	velocity.y = jump_power * JUMP_MULTIPLIER
	_coyote_jump_available = false
	_is_wall_jumping = false

func _do_wall_jump() -> void:
	velocity.y = jump_power * JUMP_MULTIPLIER
	velocity.x = _wall_side * speed * SPEED_MULTIPLIER * wall_jump_x_force
	_wall_jump_lock_timer = wall_jump_lock_duration
	_is_wall_jumping = true
	_wall_grip_timer = 0.0
	_wall_jump_ready = false

func _start_dash() -> void:
	var raw_dir := Vector2(_direction, _vertical_input)
	if raw_dir == Vector2.ZERO:
		raw_dir = Vector2(sign(_get_facing_dir()), 0.0)
	
	var snappe := Vector2(sign(raw_dir.x), sign(raw_dir.y))
	# Cardinal → pleine vitesse sur l'axe, diagonal → normalisé pour garder la même magnitude
	_dash_direction = snappe.normalized() if snappe.x != 0.0 and snappe.y != 0.0 else snappe
	
	_dash_timer = dash_duration
	_is_dashing = true
	_dash_available = false
	velocity = Vector2.ZERO

func _end_dash() -> void:
	_is_dashing = false
	_dash_cooldown_timer = dash_cooldown
	_dash_momentum_timer = dash_momentum_duration
	velocity = _dash_direction * dash_speed * dash_end_momentum

#endregion

#region État monde

func _update_wall_state(delta: float) -> void:
	if not is_on_wall_only():
		_wall_grip_timer = 0.0
		_wall_jump_ready = false
		return

	_wall_side = get_wall_normal().x
	_wall_grip_timer += delta
	if _wall_grip_timer >= wall_grip_required:
		_wall_jump_ready = true

func _update_floor_state() -> void:
	if not is_on_floor():
		if _coyote_jump_available and _coyote_timer.is_stopped():
			_coyote_timer.start()
		return

	_coyote_jump_available = true
	_coyote_timer.stop()
	_wall_jump_lock_timer = 0.0
	_wall_grip_timer = 0.0
	_wall_jump_ready = false
	_is_wall_jumping = false
	# Recharge uniquement si le cooldown est écoulé
	if _dash_cooldown_timer <= 0.0:
		_dash_available = true

#endregion

#region Calculs

func _calculate_gravity() -> float:
	if _is_dashing:
		return gravity * dash_gravity_scale
	if _is_wall_jumping:
		return gravity
	if Input.is_action_pressed("fast_fall"):
		return fast_fall_gravity
	if is_on_wall_only() and velocity.y > 0 and _direction != 0:
		return wall_gravity
	if abs(velocity.y) < apex_threshold:
		return gravity * apex_gravity_scale
	return gravity

func _get_facing_dir() -> float:
	if _direction != 0.0:
		return _direction
	return _last_facing_dir

func _make_timer(wait_time: float) -> Timer:
	var t := Timer.new()
	t.wait_time = wait_time
	t.one_shot = true
	add_child(t)
	return t

#endregion

#region Accesseurs

func get_direction() -> float:
	return _direction

func get_facing_dir() -> float:
	return _get_facing_dir()

func is_dashing() -> bool:
	return _is_dashing
	
func get_dash_fill() -> float:
	if _is_dashing:
		return 0.0
	if _dash_cooldown_timer > 0.0:
		return 1.0 - (_dash_cooldown_timer / dash_cooldown)
	if _dash_available:
		return 1.0
	return -1.0  # dash dépensé en l'air, aucun cooldown → état distinct

#endregion

#region Callbacks

func _on_coyote_timeout() -> void:
	_coyote_jump_available = false
	
func _on_damaged(amount: float) -> void:
	if is_dead:
		return

	health -= amount
	damaged.emit(amount)

	if health <= 0.0:
		is_dead = true
		died.emit()
		
func _on_died() -> void:
	is_dead = true
	set_physics_process(false)
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	SceneManager.fade_and_reload()

#endregion
