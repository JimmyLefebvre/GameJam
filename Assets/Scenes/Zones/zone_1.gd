extends Node2D

signal enemy_count_changed(remaining: int, total: int)
signal all_enemies_defeated

@onready var pause_menu = $PauseMenu

var total_enemies: int = 0
var remaining_enemies: int = 0

func _ready() -> void:
	add_to_group("zone")
	_register_enemies()
	$MusicPlayer.play(preload("res://Assets/Audio/Music/Zone1.wav"))
	$Boss.enemy_died.connect($HUD.stop_chrono) 
	$Player.first_move.connect($HUD.start_chrono)

func _register_enemies() -> void:
	var enemies := get_tree().get_nodes_in_group("enemy")
	total_enemies = enemies.size()
	remaining_enemies = total_enemies

	for enemy in enemies:
		enemy.enemy_died.connect(_on_enemy_died)

	enemy_count_changed.emit(remaining_enemies, total_enemies)

func _on_enemy_died(_enemy: EnemyBase) -> void:
	remaining_enemies -= 1
	enemy_count_changed.emit(remaining_enemies, total_enemies)

	if remaining_enemies <= 0:
		all_enemies_defeated.emit()

func _input(event):
	if event.is_action_pressed("esc"):
		pause_menu.visible = !pause_menu.visible
		get_tree().paused = pause_menu.visible

		if pause_menu.visible:
			pause_menu.get_node("Resume").call_deferred("grab_focus")
