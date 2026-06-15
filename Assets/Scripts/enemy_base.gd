extends CharacterBody2D
class_name EnemyBase
@export var player: CharacterBody2D 
@export var enemy_stats: EnemyType
@export var hitbox: HitBox
var health: float
var damage: float

var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var left_bounds: Vector2
var right_bounds: Vector2

var _is_visible: bool = false
@onready var _hurtbox: HurtBox = $HurtBox if has_node("HurtBox") else null
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $Sprite2D/RayCast2D
@onready var timer = $Timer

enum States{
	WANDER,
	CHASE
}

var current_state = States.WANDER

func _ready() -> void:
	left_bounds = self.position + Vector2(-75,0)
	right_bounds = self.position + Vector2(75,0)
	direction = Vector2(-1, 0)
	
	
	enemy_stats = enemy_stats.duplicate()
	health = enemy_stats.health
	damage = enemy_stats.damage
	set_modulate(enemy_stats.find_appearance())
	

	$VisibleOnScreenNotifier2D.screen_entered.connect(_on_screen_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	if _hurtbox:
		_hurtbox.damaged.connect(_on_damaged)
	$HitBox.damage = enemy_stats.damage
	$HitBox.activate()  # ← la hitbox ennemie est active en permanence

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
			ray_cast.target_position = Vector2(1000, 0)
		else:
			ray_cast.target_position = Vector2(-1000, 0)

	else:
		direction = (player.global_position - global_position).normalized()

		sprite.flip_h = direction.x < 0

		if direction.x > 0:
			ray_cast.target_position = Vector2(1000, 0)
		else:
			ray_cast.target_position = Vector2(-1000, 0)

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
		queue_free()

func _on_screen_entered() -> void:
	_is_visible = true

func _on_screen_exited() -> void:
	_is_visible = false


func _on_timer_timeout() -> void:
	current_state = States.WANDER
