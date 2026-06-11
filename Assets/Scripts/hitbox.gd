# hitbox.gd
extends Area2D
class_name HitBox

@export var contact_cooldown: float = 0.8  # évite les dégâts en continu
var _contact_timer: float = 0.0

@export var damage: float = 1.0
@export var debug_color: Color = Color(1.0, 0.2, 0.2, 0.4)

var _shape: CollisionShape2D

func _ready() -> void:
	_shape = get_child(0)
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)

func activate() -> void:
	monitoring = true
	monitorable = true
	queue_redraw()

func deactivate() -> void:
	monitoring = false
	monitorable = false
	queue_redraw()

func _draw() -> void:
	if not monitoring:
		return
	if _shape and _shape.shape is RectangleShape2D:
		var rect := _shape.shape as RectangleShape2D
		var r := Rect2(-rect.size / 2 + _shape.position, rect.size)
		draw_rect(r, debug_color)

func _process(delta: float) -> void:
	if _contact_timer > 0.0:
		_contact_timer -= delta

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox and _contact_timer <= 0.0:
		area.receive_hit(damage)
		_contact_timer = contact_cooldown
