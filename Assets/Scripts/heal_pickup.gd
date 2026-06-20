extends Area2D
class_name HealPickup

@export var heal_amount: float = 20.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		body.heal(heal_amount)
		queue_free()
