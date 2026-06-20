# music_player.gd
# Node réutilisable pour jouer la musique avec crossfade.
# À instancier une fois par scène ayant besoin de musique (menu, zone1, etc.)
extends Node
class_name MusicPlayer

@export var fade_duration: float = 1.0
@export var default_volume_db: float = -8.0

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer
var _current_stream: AudioStream = null
var _fade_tween: Tween = null

func _ready() -> void:
	_player_a = _make_player()
	_player_b = _make_player()
	_active_player = _player_a

func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.volume_db = -80.0
	p.bus = "Music"
	add_child(p)
	return p

# Joue une nouvelle musique avec crossfade. Ne fait rien si c'est déjà la musique active.
# Le bouclage se règle directement sur le fichier audio importé (Loop dans l'inspecteur d'import).
func play(stream: AudioStream) -> void:
	if stream == _current_stream:
		return
	_current_stream = stream

	var incoming := _player_b if _active_player == _player_a else _player_a
	var outgoing := _active_player

	incoming.stream = stream
	incoming.volume_db = -80.0
	incoming.play()

	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(incoming, "volume_db", default_volume_db, fade_duration)
	_fade_tween.tween_property(outgoing, "volume_db", -80.0, fade_duration)
	_fade_tween.set_parallel(false)
	_fade_tween.tween_callback(outgoing.stop)

	_active_player = incoming

func stop() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_active_player, "volume_db", -80.0, fade_duration)
	_fade_tween.tween_callback(_active_player.stop)
	_current_stream = null
