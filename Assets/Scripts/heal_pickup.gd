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
		if body.has_node("SfxPlayer"):
			body.get_node("SfxPlayer").play(preload("res://Assets/Audio/SFX/pickup.wav"), -8.0, 0.1)
		queue_free()
