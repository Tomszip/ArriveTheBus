extends Node2D
# Mancha de sangre que aparece donde muere alguien. La roto hacia donde iba el golpe,
# así las gotas salen "para atrás" del que recibió el tiro.

const COLOR_SANGRE := Color(0.5, 0.03, 0.03)

@export var radio_charco: float = 22.0
@export var cantidad_gotas: int = 12
@export var tiempo_crecer: float = 0.5

# Cada círculo lo guardo como [posición, radio]. No hice una clase para esto porque
# son solo dos datos y con un array alcanza.
var circulos: Array = []

# Va de 0 a 1 mientras el charco crece. Le puse un setter para que cada vez que
# el tween lo cambie se vuelva a dibujar solo.
var crecimiento: float = 0.0:
	set(valor):
		crecimiento = valor
		queue_redraw()

@onready var salpicadura: GPUParticles2D = $Salpicadura


func _ready() -> void:
	# El charco lo armo con varios círculos corridos al azar, así no queda un círculo perfecto.
	for i in 6:
		var corrimiento := Vector2(randf_range(-10, 10), randf_range(-10, 10))
		circulos.append([corrimiento, randf_range(radio_charco * 0.6, radio_charco)])

	# Las gotas van para adelante (eje X): cuanto más lejos, más abiertas.
	for i in cantidad_gotas:
		var distancia := randf_range(radio_charco, radio_charco * 3.5)
		var costado := randf_range(-distancia * 0.35, distancia * 0.35)
		circulos.append([Vector2(distancia, costado), randf_range(2.0, 6.0)])

	var tween := create_tween()
	tween.tween_property(self, "crecimiento", 1.0, tiempo_crecer) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Las partículas salen una sola vez; cuando terminan las borro para no dejar nodos colgados.
	salpicadura.emitting = true
	salpicadura.finished.connect(salpicadura.queue_free)


func _draw() -> void:
	for circulo in circulos:
		draw_circle(circulo[0] * crecimiento, circulo[1] * crecimiento, COLOR_SANGRE)
