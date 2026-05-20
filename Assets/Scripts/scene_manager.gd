extends CanvasLayer

var _overlay: ColorRect

func _ready() -> void:
	layer = 10
	_overlay = ColorRect.new()
	_overlay.name = "Overlay"
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

func fade_and_reload(duration: float = 0.8) -> void:
	await _fade_in(duration)
	get_tree().reload_current_scene()
	await _fade_out(duration)

func _fade_in(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, duration)
	await tween.finished

func _fade_out(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, duration)
	await tween.finished
