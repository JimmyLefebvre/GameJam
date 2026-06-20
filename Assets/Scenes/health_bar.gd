# health_bar.gd
extends Control

var player: PlayerController

@onready var _fill: ColorRect = $Fill
@onready var _label: Label = $Label
@onready var _background: ColorRect = $Background
@onready var _border: ColorRect = $Border

const BAR_WIDTH: float = 80.0
const BAR_HEIGHT: float = 8.0
const MARGIN: float = 8.0
const BORDER_THICKNESS: float = 1.0

func _ready() -> void:
	position = Vector2(MARGIN, MARGIN)

	_border.position = Vector2(-BORDER_THICKNESS, -BORDER_THICKNESS)
	_border.size = Vector2(BAR_WIDTH + BORDER_THICKNESS * 2, BAR_HEIGHT + BORDER_THICKNESS * 2)
	_border.color = Color.BLACK

	_background.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	_background.color = Color(0.15, 0.15, 0.15)
	
	_fill.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	_fill.color = Color(0.19, 0.635, 0.901, 1.0)
	
	_label.position = Vector2(0, BAR_HEIGHT + 2)
	_label.add_theme_font_size_override("font_size", 8)
	
	# Attend que toute la scène soit prête avant de chercher le joueur
	call_deferred("_connect_player")

func _connect_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.damaged.connect(_on_damaged)
	else:
		push_error("HealthBar: joueur introuvable dans le groupe 'player'")

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		_connect_player()
		return
	_update_bar()

func _update_bar() -> void:
	var ratio := player.health / player.max_health
	_fill.size.x = BAR_WIDTH * ratio
	_label.text = "Temps : " + str(int(player.health)) + " / " + str(int(player.max_health))

func _on_damaged(_amount: float) -> void:
	_update_bar()
