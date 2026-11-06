extends Control
# Menú con el que arranca el juego: Jugar, Opciones y Salir.
# No dejo elegir el nivel: Jugar siempre empieza en el Nivel 1 y los niveles se van
# desbloqueando pasando por la puerta, así la partida y el puntaje tienen sentido.
# Al costado muestra la tabla de mejores puntajes, que se guarda en un archivo.

# Las rutas las dejo en constantes arriba para no tener strings repetidos por el código
# y para que, si muevo una escena, lo cambie en un solo lugar.
const RUTA_PRIMER_NIVEL := "res://escenas/niveles/nivel_1.tscn"
const RUTA_OPCIONES := "res://escenas/opciones.tscn"

@onready var boton_jugar: Button = $Centro/Contenido/Fila/Botones/BotonJugar
@onready var boton_opciones: Button = $Centro/Contenido/Fila/Botones/BotonOpciones
@onready var boton_salir: Button = $Centro/Contenido/Fila/Botones/BotonSalir
@onready var lista_records: Label = $Centro/Contenido/Fila/TablaRecords/Textos/ListaRecords


func _ready() -> void:
	# Conecto las señales por código y no desde el editor porque así se ve todo junto
	# y no tengo que andar buscando en la pestaña Nodos qué botón llama a qué.
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_opciones.pressed.connect(_on_boton_opciones_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)

	mostrar_records()

	# Le doy el foco al primer botón para que también se pueda usar con el teclado (flechas + Enter).
	boton_jugar.grab_focus()


# Armo el texto de la tabla con los récords que el autoload Puntaje leyó del archivo.
func mostrar_records() -> void:
	if Puntaje.records.is_empty():
		lista_records.text = "Todavía no hay puntajes.\n¡Jugá una partida!"
		lista_records.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return

	var texto := ""
	for i in Puntaje.records.size():
		var record: Dictionary = Puntaje.records[i]
		texto += "%d.  %4d pts   %s   %s\n" % [i + 1, record["puntos"], record["llego_a"], record["fecha"]]
	# strip_edges saca el último salto de línea que sobra.
	lista_records.text = texto.strip_edges()


# Jugar siempre arranca una partida nueva desde el Nivel 1, así que el puntaje vuelve a 0.
# Los cambios de escena pasan por el autoload Transicion para que tengan fade.
func _on_boton_jugar_pressed() -> void:
	Puntaje.reiniciar()
	Transicion.cambiar_escena(RUTA_PRIMER_NIVEL)


func _on_boton_opciones_pressed() -> void:
	Transicion.cambiar_escena(RUTA_OPCIONES)


func _on_boton_salir_pressed() -> void:
	get_tree().quit()
