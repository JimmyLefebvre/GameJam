extends Node2D

@onready var pause_menu = $PauseMenu

func _input(event):
	if event.is_action_pressed("esc"):
		pause_menu.visible = !pause_menu.visible
		get_tree().paused = pause_menu.visible
