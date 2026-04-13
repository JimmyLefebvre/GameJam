extends CharacterBody2D
@export var enemy_stats: Resource
var start_position: Vector2
var moving_right: bool
var _is_visible: bool = false

func _ready():
	set_modulate(enemy_stats.find_appearance())
	find_starting_direction()
	start_position = position
	$VisibleOnScreenNotifier2D.screen_entered.connect(_on_screen_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta):
	if not _is_visible:
		return
	move_enemy(delta)
	velocity.y += 10
	move_and_slide()

func move_enemy(delta):
	var direction = Vector2.ZERO
	if moving_right:
		direction.x += 1
	else:
		direction.x -= 1
	position += direction.normalized() * enemy_stats.speed * delta
	if position.x >= start_position.x + enemy_stats.movement_range:
		moving_right = false
	elif position.x <= start_position.x - enemy_stats.movement_range:
		moving_right = true

func find_starting_direction():
	var array: Array = [1, 2]
	array.shuffle()
	moving_right = array.front() == 1

func _on_screen_entered() -> void:
	_is_visible = true

func _on_screen_exited() -> void:
	_is_visible = false
