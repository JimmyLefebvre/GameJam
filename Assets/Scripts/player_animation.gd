extends Node2D

@export var player_control: PlayerController
@export var attack_manager: AttackManager
@export var sprite: Sprite2D # Ton unique Sprite2D

@onready var _tree: AnimationTree = $AnimationTree
@onready var _state: AnimationNodeStateMachinePlayback = _tree["parameters/playback"]

var _blink_tween: Tween = null
var _is_blinking: bool = false
var _dash_anim_timer: float = 0.0

const DASH_ANIM_DURATION: float = 0.15

func _ready() -> void:
	player_control.damaged.connect(_on_damaged)
	attack_manager.attack_started.connect(_on_attack_started)
	attack_manager.attack_ended.connect(_on_attack_ended)

func _process(delta: float) -> void:
	if _dash_anim_timer > 0.0:
		_dash_anim_timer -= delta
	_update_flip()
	_update_state()

func _update_flip() -> void:
	# On récupère la direction du regard. 
	# Pendant une attaque, l'AttackManager change la direction, donc on se base dessus.
	var facing := player_control.get_facing_dir()
	if facing != 0.0:
		sprite.flip_h = facing < 0.0

func _update_state() -> void:
	# Si on est en train d'attaquer, on bloque les animations de mouvement (idle, move, jump...)
	if attack_manager.is_attacking:
		return

	var vel := player_control.velocity

	if player_control.is_dashing():
		_dash_anim_timer = DASH_ANIM_DURATION
		_state.travel("dash")
		return

	if _dash_anim_timer > 0.0:
		return

	if vel.y < 0.0:
		_state.travel("jump")
		return

	if vel.y > 0.0:
		_state.travel("fall")
		return

	if abs(vel.x) > 0.0:
		_state.travel("move")
	else:
		_state.travel("idle")

func _on_attack_started(direction: Vector2) -> void:
	# On trie uniquement entre l'attaque vers le bas et l'attaque de côté
	if direction == Vector2.DOWN:
		_state.travel("attack_down")
	else:
		# Pour UP, LEFT, et RIGHT -> On joue l'attaque de côté générale.
		# Le flip_h dans _update_flip() s'occupe de la retourner si on regarde à gauche.
		_state.travel("attack_side")

func _on_attack_ended() -> void:
	# On réévalue immédiatement l'état (idle, move, etc.) dès que le coup est fini
	_update_state()

func _on_damaged(_amount: float) -> void:
	if _is_blinking:
		return
	_start_blink()

func _start_blink() -> void:
	_is_blinking = true
	sprite.modulate.a = 1.0
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
	_blink_tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(player_control.iframe_duration).timeout

	if _blink_tween:
		_blink_tween.kill()
		_blink_tween = null
	sprite.modulate.a = 1.0
	_is_blinking = false
