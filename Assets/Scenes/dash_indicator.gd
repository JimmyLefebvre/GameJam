extends Node2D
class_name DashIndicator

@export var player: PlayerController

# Apparence
@export var radius: float = 12.0          # rayon de l'arc
@export var thickness: float = 3.0        # épaisseur du trait
@export var offset: Vector2 = Vector2(0, -24)  # position relative au joueur

@export var color_ready: Color = Color(0.4, 0.8, 1.0)    # bleu quand rechargé
@export var color_charging: Color = Color(0.58, 0.0, 0.09, 0.5) # gris pendant le cooldown

# Interne
var _fill: float = 1.0  # 0.0 → 1.0

func _ready() -> void:
	position = offset

func _process(_delta: float) -> void:
	_update_fill()
	queue_redraw()

func _update_fill() -> void:
	_fill = player.get_dash_fill()

func _draw() -> void:
	# Fond toujours affiché
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 128, Color(0.0, 0.0, 0.0), thickness)

	if _fill < 0.0:
		# Dash dépensé en l'air → cercle complet rouge
		draw_arc(Vector2.ZERO, radius, -PI / 2.0, -PI / 2.0 + TAU, 128, color_charging, thickness, true)
	elif _fill >= 1.0:
		# Rechargé → cercle complet bleu
		draw_arc(Vector2.ZERO, radius, -PI / 2.0, -PI / 2.0 + TAU, 128, color_ready, thickness, true)
	elif _fill > 0.0:
		# En cours de recharge → arc noir
		var start_angle := -PI / 2.0
		var end_angle := start_angle + TAU * _fill
		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 128, Color(0.58, 0.0, 0.09), thickness, true)
