extends Area2D
# Puerta de salida del nivel (el punto B). La armé como escena aparte para usar la
# misma en los dos niveles: en cada uno solo la pongo pegada a una pared y la giro.
# El dibujo está pensado para una pared de ARRIBA; si la pared está a la derecha,
# en el nivel le pongo rotation 90° y queda bien.
# No sabe nada de ganar: el nivel escucha su body_entered y decide qué pasa.

# Cuánto gira la hoja al abrirse (un poco más de 90° para que se vea bien abierta).
const ANGULO_ABIERTA := deg_to_rad(100.0)
const DURACION_TITILEO := 0.8

@onready var hoja: Polygon2D = $Hoja
@onready var luz: Polygon2D = $Luz
@onready var cartel: Node2D = $Cartel


func _ready() -> void:
	# El cartel "SALIDA" gira con la puerta; le saco el giro para que el texto quede derecho.
	cartel.rotation = -rotation

	# La luz titila todo el tiempo para que la puerta se note desde lejos.
	# set_loops() sin número repite para siempre (se corta solo cuando se borra la puerta).
	var tween := create_tween().set_loops()
	tween.tween_property(luz, "modulate:a", 0.35, DURACION_TITILEO)
	tween.tween_property(luz, "modulate:a", 1.0, DURACION_TITILEO)


# La llama el nivel cuando llego. La hoja tiene el origen en la bisagra,
# así que con solo girarla parece que la puerta se abre hacia adentro.
func abrir() -> void:
	var tween := create_tween()
	tween.tween_property(hoja, "rotation", ANGULO_ABIERTA, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
