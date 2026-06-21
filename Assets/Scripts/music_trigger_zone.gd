extends Area2D

@export var music: AudioStream                  # Boss.wav
@export var music_player_path: NodePath         # chemin vers le MusicPlayer de la zone
@export var boss_camera: Node2D                 # la PhantomCamera2D de la salle du boss
@export var once: bool = true

@export var boss: Boss
var boss_health_bar_path: NodePath

var _triggered: bool = false
@onready var _music_player: MusicPlayer = get_node(music_player_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if once and _triggered:
		return
	if body is PlayerController:
		_triggered = true
		_music_player.play(music)
		boss_camera.priority = 10
		var bar := get_tree().get_first_node_in_group("boss_health_bar")
		if bar:
			bar.activate(boss)
