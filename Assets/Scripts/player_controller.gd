extends CharacterBody2D
class_name player_controller
#region Variables
@export var speed := 10.0
@export var jump_power := 10.0

var speed_multiplier := 30.0  # multiplicateur de vitesse horizontale
var jump_multiplier := -30.0  # négatif car l’axe Y va vers le bas dans Godot

# Gravité
var gravity := 800.0
var fast_fall_gravity := 1000.0  # gravité augmentée quand on appuie vers le bas
var wall_gravity := 100.0        # gravité réduite lors du slide contre un mur

# Limites vitesse verticale (évite chute infinie)
var max_fall_speed := 400.0
var max_fast_fall_speed := 600.0

# Apex (sommet du saut → sensation de flottement)
var apex_threshold := 20.0       # zone proche du sommet du saut
var apex_gravity_scale := 0.5    # gravité réduite à l’apex

# Mouvement horizontal
var acceleration := 1800.0       # vitesse d’accélération vers la vitesse cible

# Wall jump
var wall_jump_x_force := 1.0     # force horizontale du saut mural
var wall_jump_lock_duration := 0.2  # temps pendant lequel le joueur ne peut pas contrôler le mouvement après un wall jump
var wall_jump_lock_timer := 0.0
var is_wall_jumping := false     # indique si on est en train de faire un wall jump

var direction := 0.0             # input horizontal (-1 à 1)
var wall_side := 0.0             # direction du mur (normal du mur)

# Timers
var input_buffer : Timer         # permet d'enregistrer un saut légèrement en avance
var coyote_timer : Timer         # permet de sauter juste après avoir quitté le sol
var coyote_jump_available := true

const INPUT_BUFFER_PATIENCE = 0.1
const COYOTE_TIME = 0.1
#endregion
func _ready() -> void:
	# Création du timer de buffer d'input
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)

	# Création du timer de coyote time
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)

func _physics_process(delta: float) -> void:
	# Récupère l’input horizontal (-1 gauche, 1 droite)
	direction = Input.get_axis("move_left", "move_right")

	# Détecte un appui sur saut
	var jump_attempted := Input.is_action_just_pressed("jump")

	# Si on est collé à un mur, on récupère sa normale
	if is_on_wall_only():
		wall_side = get_wall_normal().x  # ⚠️ attention: valeur inversée par rapport au côté réel du mur

	# Gestion du saut (sol + mur + buffer)
	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available:
			# Saut classique (ou coyote time)
			velocity.y = jump_power * jump_multiplier
			coyote_jump_available = false
			is_wall_jumping = false

		elif is_on_wall_only():
			# Wall jump
			velocity.y = jump_power * jump_multiplier
			velocity.x = wall_side * speed * speed_multiplier * wall_jump_x_force
			wall_jump_lock_timer = wall_jump_lock_duration
			is_wall_jumping = true

		elif jump_attempted:
			# Stocke l’input si saut impossible (input buffer)
			input_buffer.start()

	# Saut variable (plus tu relâches tôt, plus le saut est petit)
	# Désactivé pendant wall jump
	if Input.is_action_just_released("jump") and velocity.y < 0 and not is_wall_jumping:
		velocity.y *= 0.4

	# Gestion sol / air
	if is_on_floor():
		# Reset des états quand on touche le sol
		coyote_jump_available = true
		coyote_timer.stop()
		wall_jump_lock_timer = 0.0
		is_wall_jumping = false
	else:
		# Lance le coyote time si on vient de quitter le sol
		if coyote_jump_available and coyote_timer.is_stopped():
			coyote_timer.start()

		# Application de la gravité
		velocity.y += calculate_gravity(direction) * delta

		# Limitation de la vitesse verticale (évite accélération infinie)
		if Input.is_action_pressed("fast_fall"):
			# chute rapide (input bas)
			velocity.y = min(velocity.y, max_fast_fall_speed)
		else:
			# chute normale
			velocity.y = min(velocity.y, max_fall_speed)

	# Mouvement horizontal avec inertie
	if wall_jump_lock_timer > 0.0:
		# Pendant un wall jump, on bloque le contrôle
		wall_jump_lock_timer -= delta
		if wall_jump_lock_timer <= 0.0:
			is_wall_jumping = false
	else:
		# Accélération progressive vers la vitesse cible
		var target_x := direction * speed * speed_multiplier
		velocity.x = move_toward(velocity.x, target_x, acceleration * delta)

	# Applique le mouvement et gère les collisions
	move_and_slide()

func calculate_gravity(input_dir: float = 0) -> float:
	# Gravité constante pendant un wall jump
	if is_wall_jumping:
		return gravity

	# Fast fall → gravité plus forte
	if Input.is_action_pressed("fast_fall"):
		return fast_fall_gravity

	# Slide sur mur → chute lente
	if is_on_wall_only() and velocity.y > 0 and input_dir != 0:
		return wall_gravity

	# Apex → flottement au sommet du saut
	if not is_on_floor() and abs(velocity.y) < apex_threshold:
		return gravity * apex_gravity_scale

	return gravity

func coyote_timeout() -> void:
	# Fin du coyote time
	coyote_jump_available = false
