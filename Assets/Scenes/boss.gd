extends CharacterBody2D
class_name Boss

signal enemy_died(enemy: Boss)

@export var player: CharacterBody2D 
@export var enemy_stats: EnemyType
@export var hitbox: HitBox
@export var patrol_distance: float = 75.0
@export var blink_duration: float = 0.4
@export var blink_interval: float = 0.1
@export var death_fade_duration: float = 0.4
var health: float
var damage: float

var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var left_bounds: Vector2
var right_bounds: Vector2

var _is_visible: bool = false
@onready var _hurtbox: HurtBox = $HurtBox if has_node("HurtBox") else null
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $AnimatedSprite2D/RayCast2D
@onready var timer = $Timer

enum States{
	WANDER,
	CHASE
}

var current_state = States.WANDER

var _blink_tween: Tween = null
var _is_blinking: bool = false

func _ready() -> void:
	add_to_group("boss")
	left_bounds = self.position + Vector2(-patrol_distance, 0)
	right_bounds = self.position + Vector2(patrol_distance, 0)
	direction = Vector2(-1, 0)
	
	
	enemy_stats = enemy_stats.duplicate()
	health = enemy_stats.health
	damage = enemy_stats.damage
	

	$VisibleOnScreenNotifier2D.screen_entered.connect(_on_screen_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	if _hurtbox:
		_hurtbox.damaged.connect(_on_damaged)
	$HitBox.damage = enemy_stats.damage
	$HitBox.activate()  # ← la hitbox ennemie est active en permanence

	sprite.play("default")

func _physics_process(delta):
	handle_gravity(delta)
	
	# L'ennemi ne s'arrête hors de l'écran QUE s'il est en mode WANDER
	if not _is_visible and current_state == States.WANDER:
		velocity.x = 0
		move_and_slide()
		return

	handle_movement(delta)

	if is_on_wall():
		direction.x *= -1

	change_direction()
	look_for_player()

func change_direction() -> void:
	if current_state == States.WANDER:

		# Arrivé à gauche -> aller à droite
		if position.x <= left_bounds.x:
			direction.x = 1

		# Arrivé à droite -> aller à gauche
		elif position.x >= right_bounds.x:
			direction.x = -1

		sprite.flip_h = direction.x < 0

		if direction.x > 0:
			ray_cast.target_position = Vector2(400, 0)
		else:
			ray_cast.target_position = Vector2(-400, 0)

	else:
		direction = (player.global_position - global_position).normalized()

		sprite.flip_h = direction.x < 0

		if direction.x > 0:
			ray_cast.target_position = Vector2(400, 0)
		else:
			ray_cast.target_position = Vector2(-400, 0)

	ray_cast.force_raycast_update()

func handle_movement(delta:float) -> void:
	velocity.x = move_toward(velocity.x, direction.x * enemy_stats.speed, delta * 300)
	move_and_slide()

func handle_gravity(delta:float) -> void:
	if not is_on_floor():
		# --- CORRECTION ICI ---
		# On multiplie par delta pour une accélération linéaire et fluide
		velocity.y += gravity * delta 
		# ----------------------

func look_for_player():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()
		
func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE
	

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()



func _on_damaged(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		_die()
		return
	_play_hit_sfx()
	_start_blink()

func _die() -> void:
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	if _hurtbox:
		_hurtbox.set_deferred("monitoring", false)
	$HitBox.deactivate()
	_play_death_sfx()
	enemy_died.emit(self)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(1.0, 0.2, 0.2, 0.0), death_fade_duration)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func _play_death_sfx() -> void:
	# Joué via le joueur pour que le son survive après queue_free() de l'ennemi
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_node("SfxPlayer"):
		p.get_node("SfxPlayer").play(preload("res://Assets/Audio/SFX/enemy_death.wav"), -10, 0.1)

func _play_hit_sfx() -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and p.has_node("SfxPlayer"):
		p.get_node("SfxPlayer").play(preload("res://Assets/Audio/SFX/hitE.wav"), -25.0, 0.2)

func _start_blink() -> void:
	if _is_blinking:
		return
	_is_blinking = true
	sprite.modulate = Color.WHITE
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(sprite, "modulate", Color(1.0, 0.2, 0.2), blink_interval)
	_blink_tween.tween_property(sprite, "modulate", Color.WHITE, blink_interval)

	await get_tree().create_timer(blink_duration).timeout

	if _blink_tween:
		_blink_tween.kill()
		_blink_tween = null
	sprite.modulate = Color.WHITE
	_is_blinking = false

func _on_screen_entered() -> void:
	_is_visible = true


func _on_screen_exited() -> void:
	_is_visible = false


func _on_timer_timeout() -> void:
	current_state = States.WANDER
