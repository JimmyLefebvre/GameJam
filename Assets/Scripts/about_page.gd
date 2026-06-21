extends Node2D

func _ready() -> void:
	$MusicPlayer.play(preload("res://Assets/Audio/Music/mainMenu.wav"))
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")
