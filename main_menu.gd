extends Node2D

var button_type = null

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Zones/zone_1.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
