# music_trigger_zone.gd
# Area2D à placer dans la scène pour déclencher un changement de musique
# quand le joueur entre dans une zone (ex: avant un combat de boss).
extends Area2D
class_name MusicTriggerZone

@export var music: AudioStream
@export var music_player_path: NodePath  # chemin vers le MusicPlayer de la scène
@export var once: bool = true  # ne se déclenche qu'une fois (ex: entrée dans l'arène du boss)

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
