# sfx_player.gd
# Node réutilisable pour jouer des effets sonores ponctuels.
# À instancier une fois par scène (Player, Enemy, HUD, etc.)
# Permet plusieurs sons simultanés sans se couper grâce à une pool de players.
extends Node
class_name SfxPlayer

@export var pool_size: int = 6
@export var bus: String = "SFX"

var _pool: Array[AudioStreamPlayer] = []
var _next_index: int = 0

func _ready() -> void:
	for i in pool_size:
		var p := AudioStreamPlayer.new()
		p.bus = bus
		add_child(p)
		_pool.append(p)

# Joue un son. pitch_variation ajoute une légère variation aléatoire pour éviter
# l'effet "mitraillette" sur les sons répétés (pas, hits).
func play(stream: AudioStream, volume_db: float = 0.0, pitch_variation: float = 0.0) -> void:
	if stream == null:
		return
	var p := _pool[_next_index]
	_next_index = (_next_index + 1) % _pool.size()

	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	p.play()
