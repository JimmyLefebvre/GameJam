extends StaticBody2D
class_name BossBlock

func _ready() -> void:
	call_deferred("_connect_zone")

func _connect_zone() -> void:
	var zone := get_tree().get_first_node_in_group("zone")
	if zone:
		zone.all_enemies_defeated.connect(_on_unlocked)

func _on_unlocked() -> void:
	queue_free()
