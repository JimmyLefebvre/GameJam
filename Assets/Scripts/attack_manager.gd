# attack_manager.gd
extends Node2D
class_name AttackManager

signal attack_started(direction: Vector2)
signal attack_ended

@export var player: PlayerController
@export var attack_duration: float = 0.4
@export var attack_cooldown: float = 0.05
@export_group("HitBoxes")
@export var hitbox_right: HitBox
@export var hitbox_left: HitBox
@export var hitbox_down: HitBox

var is_attacking: bool = false
var _cooldown_timer: float = 0.0
var _attack_timer: float = 0.0
var _active_hitbox: HitBox = null
var _temps_dernier_toucher: int = 0

func _input(event: InputEvent) -> void:
	# Dès qu'un doigt touche ou glisse sur l'écran, on enregistre l'heure exacte
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_temps_dernier_toucher = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if is_attacking:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_end_attack()
		return

	var veut_attaquer = false

	# 1. Le bouton d'attaque mobile a été pressé directement
	if Input.is_action_just_pressed("attack_mobile"):
		veut_attaquer = true
		
	# 2. Le clic gauche (souris PC) a été pressé
	elif Input.is_action_just_pressed("attack"):
		# SÉCURITÉ : Si l'écran tactile a été touché il y a moins de 100 millisecondes,
		# c'est un faux clic de navigateur web ! On ne valide pas l'attaque.
		if Time.get_ticks_msec() - _temps_dernier_toucher > 100:
			veut_attaquer = true

	# On lance l'attaque si l'une des deux conditions est bonne
	if veut_attaquer and _cooldown_timer <= 0.0:
		_start_attack(_get_attack_direction())


func _get_attack_direction() -> Vector2:
	var vertical := Input.get_axis("move_up", "fast_fall")
	var horizontal := Input.get_axis("move_left", "move_right")

	if vertical > 0.0:
		return Vector2.DOWN
	if horizontal != 0.0:
		return Vector2(horizontal, 0.0)
	return Vector2(player.get_facing_dir(), 0.0)

func _start_attack(dir: Vector2) -> void:
	is_attacking = true
	_attack_timer = attack_duration
	_active_hitbox = _hitbox_for_direction(dir)
	_active_hitbox.activate()
	attack_started.emit(dir)
	$SfxPlayer.play(preload("res://Assets/Audio/SFX/attack.mp3"), -15.0, 0.15)

func _end_attack() -> void:
	is_attacking = false
	_cooldown_timer = attack_cooldown
	if _active_hitbox:
		_active_hitbox.deactivate()
		_active_hitbox = null
	attack_ended.emit()

func _hitbox_for_direction(dir: Vector2) -> HitBox:
	if dir == Vector2.DOWN:
		return hitbox_down
	if dir.x < 0.0:
		return hitbox_left
	return hitbox_right
