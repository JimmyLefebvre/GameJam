extends Node2D

var button_type = null

func _ready() -> void:
	$MusicPlayer.play(preload("res://Assets/Audio/Music/mainMenu.wav"))

func _on_start_pressed() -> void:
	Settings.chrono_active = $CheckBox.button_pressed
	get_tree().change_scene_to_file("res://Assets/Scenes/Zones/zone_1.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/controls.tscn")
