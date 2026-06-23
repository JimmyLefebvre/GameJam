extends CanvasLayer

@onready var chrono_label = $ChronoLabel

var chrono_en_cours := false
var temps_depart := 0

func _ready() -> void:
	# Settings only control visibility, NOT whether the clock is ticking yet
	chrono_label.visible = Settings.chrono_active


func _process(_delta: float) -> void:
	if chrono_en_cours:
		_update_display()


func start_chrono() -> void:
	# Only start if the setting allows it
	if Settings.chrono_active:
		temps_depart = Time.get_ticks_msec()
		chrono_en_cours = true


func stop_chrono(_enemy) -> void:
	# Only stop and finalize if it was actually running
	if chrono_en_cours:
		chrono_en_cours = false
		_update_display()


# Helper function to prevent duplicating your code
func _update_display() -> void:
	var total_msec = Time.get_ticks_msec() - temps_depart
	var total_sec = int(total_msec / 1000.0) 
	
	var minutes = int(total_sec / 60.0)
	var seconds = total_sec % 60
	var centiseconds = int((total_msec % 1000) / 10.0)

	chrono_label.text = "Chrono : %02d:%02d;%02d" % [minutes, seconds, centiseconds]
