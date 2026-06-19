extends CanvasLayer

func _ready():
	visible = false

func _on_resume_pressed():
	visible = false
	get_tree().paused = false

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")
