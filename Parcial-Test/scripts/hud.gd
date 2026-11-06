extends CanvasLayer
# Capa de interfaz de cada nivel. Arriba tengo tres paneles con el mismo estilo que
# el menú (le puse el mismo Theme al nodo Marcador): el nivel, el cargador y el puntaje.
# En el medio de la pantalla está el cartel de ganar/perder, que arranca escondido.

# Colores de la etiqueta del cargador: naranja normal, amarillo recargando, rojo sin balas.
const COLOR_NORMAL := Color(0.95, 0.6, 0.2)
const COLOR_AVISO := Color(0.95, 0.78, 0.25)
const COLOR_PELIGRO := Color(0.9, 0.2, 0.15)
# Cada bala del cargador es un rectangulito: dorado si está cargada, gris si ya la disparé.
const COLOR_BALA_CARGADA := Color(1, 0.82, 0.3)
const COLOR_BALA_VACIA := Color(0.32, 0.32, 0.34)
const TAMANO_BALA := Vector2(7, 20)

@onready var cartel: Control = $Cartel
@onready var titulo: Label = $Cartel/Panel/VBox/Titulo
@onready var ayuda: Label = $Cartel/Panel/VBox/Ayuda
@onready var etiqueta_nivel: Label = $Marcador/PanelNivel/Textos/Etiqueta
@onready var nombre_nivel: Label = $Marcador/PanelNivel/Textos/Valor
@onready var etiqueta_cargador: Label = $Marcador/PanelMunicion/Textos/Etiqueta
@onready var balas: HBoxContainer = $Marcador/PanelMunicion/Textos/Fila/Balas
@onready var texto_reserva: Label = $Marcador/PanelMunicion/Textos/Fila/Reserva
@onready var texto_puntaje: Label = $Marcador/PanelPuntaje/Textos/Valor


func _ready() -> void:
	# Me conecto a la señal del autoload en vez de leer el puntaje en cada frame:
	# así solo cambio el texto cuando de verdad cambió el número.
	Puntaje.puntaje_cambio.connect(actualizar_puntaje)
	actualizar_puntaje(Puntaje.puntos)


func actualizar_puntaje(puntos: int) -> void:
	texto_puntaje.text = str(puntos)


# El nivel me pasa algo como "Nivel 1: El Conventillo". Lo parto en el ":" para
# mostrar "NIVEL 1" chiquito arriba y el nombre grande abajo.
func mostrar_nombre_nivel(nombre: String) -> void:
	etiqueta_nivel.text = nombre.get_slice(":", 0).to_upper()
	nombre_nivel.text = nombre.get_slice(":", 1).strip_edges()


# El nivel me llama a esto al arrancar con el tamaño del cargador del jugador.
# Creo una balita por cada bala que entra, así si cambio el tamaño del cargador
# en el inspector del jugador, el HUD se acomoda solo.
func preparar_cargador(tamano: int) -> void:
	for i in tamano:
		var bala := ColorRect.new()
		bala.custom_minimum_size = TAMANO_BALA
		bala.mouse_filter = Control.MOUSE_FILTER_IGNORE
		balas.add_child(bala)


# La conecta el nivel a la señal municion_cambio del jugador.
func actualizar_municion(en_cargador: int, en_reserva: int, recargando: bool) -> void:
	# Pinto de dorado las balas que me quedan y de gris las que ya disparé.
	for i in balas.get_child_count():
		var bala: ColorRect = balas.get_child(i)
		if i < en_cargador:
			bala.color = COLOR_BALA_CARGADA
		else:
			bala.color = COLOR_BALA_VACIA

	texto_reserva.text = "Reserva: %d" % en_reserva

	if recargando:
		etiqueta_cargador.text = "RECARGANDO..."
		etiqueta_cargador.add_theme_color_override("font_color", COLOR_AVISO)
	elif en_cargador == 0 and en_reserva == 0:
		etiqueta_cargador.text = "¡SIN BALAS!"
		etiqueta_cargador.add_theme_color_override("font_color", COLOR_PELIGRO)
	else:
		etiqueta_cargador.text = "CARGADOR"
		etiqueta_cargador.add_theme_color_override("font_color", COLOR_NORMAL)


# El nivel me llama a esto cuando gano o pierdo. Uso un solo cartel para las dos cosas
# y le cambio el texto, así no tengo que armar dos pantallas casi iguales.
func mostrar_mensaje(texto_titulo: String, texto_ayuda: String) -> void:
	titulo.text = texto_titulo
	ayuda.text = texto_ayuda
	cartel.show()
