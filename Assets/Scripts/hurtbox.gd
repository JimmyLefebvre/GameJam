# hurtbox.gd
extends Area2D
class_name HurtBox

signal damaged(amount: float)

func receive_hit(amount: float) -> void:
	damaged.emit(amount)
