extends Node2D

@export var player_control: PlayerController
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D

func _process(_delta: float) -> void:
	_update_flip()
	_update_animation()

func _update_flip() -> void:
	var facing := player_control.get_facing_dir()
	if facing != 0.0:
		sprite.flip_h = facing < 0.0

func _update_animation() -> void:
	var vel := player_control.velocity

	#if player_control.is_dashing():
		#animation_player.play("dash")
		#return pour quand on en aura une

	if vel.y < 0.0:
		animation_player.play("jump")
		return

	if vel.y > 0.0:
		animation_player.play("fall")
		return

	if abs(vel.x) > 0.0:
		animation_player.play("move")
	else:
		animation_player.play("idle")
