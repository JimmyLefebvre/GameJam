# hitbox.gd
extends Area2D
class_name HitBox

@export var damage: float = 10.0
@export var debug_color: Color = Color(1.0, 0.2, 0.2, 0.4)
@export var continuous: bool = true  # true = frappe en boucle (ennemis), false = un seul hit par activation (joueur)

var _shape: CollisionShape2D
var _already_hit: Array = []

func _ready() -> void:
	_shape = get_child(0)
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)

func activate() -> void:
	monitoring = true
	monitorable = true
	_already_hit.clear()
	queue_redraw()

func deactivate() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	_already_hit.clear()
	queue_redraw()

func _draw() -> void:
	if not monitoring:
		return
	if _shape and _shape.shape is RectangleShape2D:
		var rect := _shape.shape as RectangleShape2D
		var r := Rect2(-rect.size / 2 + _shape.position, rect.size)
		draw_rect(r, debug_color)

func _physics_process(_delta: float) -> void:
	if not monitoring or not continuous:
		return
	# Détecte les hurtbox qui sont déjà dans la zone (contact continu)
	for area in get_overlapping_areas():
		if area is HurtBox:
			area.receive_hit(damage)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		if continuous:
			area.receive_hit(damage)
		elif not _already_hit.has(area):
			_already_hit.append(area)
			area.receive_hit(damage)
