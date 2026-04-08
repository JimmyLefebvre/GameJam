extends Node2D

@export var player_control : player_controller
@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D

func _process(_delta):
	if player_control.direction == 1:
		sprite.flip_h = false
	elif player_control.direction == -1:
		sprite.flip_h = true
		
	if abs(player_control.velocity.x) > 0.0:
		animation_player.play("move")
	else:
		animation_player.play("idle")
		
	if player_control.velocity.y < 0.0:
		animation_player.play("jump")
	elif player_control.velocity.y > 0.0:
		animation_player.play("fall")
		
		
