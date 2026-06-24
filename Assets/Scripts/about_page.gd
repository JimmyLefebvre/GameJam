extends Node2D

func _ready() -> void:
	$MusicPlayer.play(preload("res://Assets/Audio/Music/mainMenu.wav"))
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")

func _input(event: InputEvent) -> void:
	# Si le joueur appuie sur le bouton retour de la manette
	if event.is_action_pressed("ui_cancel"):
		# On appelle directement la fonction du bouton Back
		_on_back_pressed()
