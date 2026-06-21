# enemy_counter.gd
extends Control

@onready var _label: Label = $Label

var _zone: Node = null

func _ready() -> void:
	_label.add_theme_font_size_override("font_size", 16)
	call_deferred("_connect_zone")

func _connect_zone() -> void:
	_zone = get_tree().get_first_node_in_group("zone")
	if _zone:
		_zone.enemy_count_changed.connect(_on_enemy_count_changed)
		_on_enemy_count_changed(_zone.remaining_enemies, _zone.total_enemies)
	else:
		push_error("EnemyCounter: zone introuvable dans le groupe 'zone'")

func _on_enemy_count_changed(remaining: int, total: int) -> void:
	var defeated := total - remaining
	_label.text = str(defeated) + "/" + str(total)
