# boss_health_bar.gd
extends Control

@export var boss: Boss

@onready var _fill: ColorRect = $Fill
@onready var _label: Label = $Label
@onready var _background: ColorRect = $Background
@onready var _border: ColorRect = $Border

const BAR_WIDTH: float = 200.0
const BAR_HEIGHT: float = 14.0
const BORDER_THICKNESS: float = 2.0

var _max_health: float = 0.0

func _ready() -> void:
	add_to_group("boss_health_bar")
	visible = false

	_border.position = Vector2(-BORDER_THICKNESS, -BORDER_THICKNESS)
	_border.size = Vector2(BAR_WIDTH + BORDER_THICKNESS * 2, BAR_HEIGHT + BORDER_THICKNESS * 2)
	_border.color = Color.BLACK

	_background.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	_background.color = Color(0.15, 0.15, 0.15)

	_fill.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	_fill.color = Color(0.8, 0.15, 0.15)

	_label.position = Vector2(0, BAR_HEIGHT + 2)
	_label.add_theme_font_size_override("font_size", 14)

# Appelée par le trigger de la salle du boss (même Area2D que caméra/musique)
func activate(target: Boss) -> void:
	boss = target
	_max_health = boss.enemy_stats.health
	visible = true
	boss.enemy_died.connect(_on_boss_died)

func _process(_delta: float) -> void:
	if not visible or not is_instance_valid(boss):
		return
	_update_bar()

func _update_bar() -> void:
	var ratio := boss.health / _max_health
	_fill.size.x = BAR_WIDTH * ratio
	_label.text = str(int(boss.health)) + " / " + str(int(_max_health))

func _on_boss_died(_b: Boss) -> void:
	visible = false
