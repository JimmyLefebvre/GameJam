# victory_screen.gd
extends Control

func _ready() -> void:
	add_to_group("victory_screen")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("_connect_boss")

func _connect_boss() -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss:
		boss.enemy_died.connect(_on_boss_died)

func _on_boss_died(_b) -> void:
	await get_tree().create_timer(2.0).timeout

	visible = true

	await get_tree().create_timer(3.0).timeout

	get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")
