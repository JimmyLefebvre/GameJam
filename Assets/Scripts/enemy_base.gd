extends CharacterBody2D

@export var enemy_stats: Resource

var start_position: Vector2
var moving_right: bool

func _ready():
	set_modulate(enemy_stats.find_appearance())
	find_starting_direction()
	start_position = position

func _process(delta):
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
	if array.front() == 1:
		moving_right = true
	else:
		moving_right = false
