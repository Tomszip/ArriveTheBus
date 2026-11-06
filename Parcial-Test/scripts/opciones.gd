extends Control
# Submenú de opciones: volumen general y resolución de la ventana.
# No guardo las opciones en ningún archivo: el volumen queda en el AudioServer y el
# tamaño en la ventana, y los dos siguen así mientras el juego esté abierto aunque cambie de escena.

const RUTA_MENU := "res://escenas/menu_principal.tscn"
# Las resoluciones que ofrezco. Todas son 16:9 para que el juego no se vea estirado.
const RESOLUCIONES := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
# El bus 0 siempre es "Master", que es por donde pasa todo el sonido del juego.
const BUS_MASTER := 0

@onready var barra_volumen: HSlider = $Centro/Contenido/FilaVolumen/BarraVolumen
@onready var texto_porcentaje: Label = $Centro/Contenido/FilaVolumen/Porcentaje
@onready var selector_resolucion: OptionButton = $Centro/Contenido/FilaResolucion/SelectorResolucion
@onready var boton_volver: Button = $Centro/Contenido/BotonVolver


func _ready() -> void:
	# Cargo las opciones del selector desde el array, así si quiero agregar una
	# resolución nueva solo la sumo arriba y no toco la escena.
	for resolucion in RESOLUCIONES:
		selector_resolucion.add_item("%d x %d" % [resolucion.x, resolucion.y])

	# Pongo los controles como están ahora. Si no hiciera esto, al volver a entrar
	# a Opciones la barra aparecería siempre al máximo aunque haya bajado el volumen.
	# El AudioServer trabaja en decibeles y la barra va de 0 a 1, por eso convierto.
	if AudioServer.is_bus_mute(BUS_MASTER):
		barra_volumen.value = 0.0
	else:
		barra_volumen.value = db_to_linear(AudioServer.get_bus_volume_db(BUS_MASTER))
	actualizar_porcentaje()

	var indice_actual := RESOLUCIONES.find(get_window().size)
	if indice_actual != -1:
		selector_resolucion.select(indice_actual)

	# Conecto después de setear los valores, porque si no al poner barra_volumen.value
	# se dispararía la señal y cambiaría el volumen sin que nadie toque nada.
	barra_volumen.value_changed.connect(_on_barra_volumen_value_changed)
	selector_resolucion.item_selected.connect(_on_selector_resolucion_item_selected)
	boton_volver.pressed.connect(_on_boton_volver_pressed)

	barra_volumen.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	# Con Esc también vuelvo al menú, igual que en los niveles.
	if event.is_action_pressed("ui_cancel"):
		_on_boton_volver_pressed()


func _on_barra_volumen_value_changed(valor: float) -> void:
	# linear_to_db(0) da menos infinito, así que en 0 directamente silencio el bus.
	AudioServer.set_bus_mute(BUS_MASTER, valor <= 0.0)
	if valor > 0.0:
		AudioServer.set_bus_volume_db(BUS_MASTER, linear_to_db(valor))
	actualizar_porcentaje()


func actualizar_porcentaje() -> void:
	texto_porcentaje.text = "%d%%" % roundi(barra_volumen.value * 100)


func _on_selector_resolucion_item_selected(indice: int) -> void:
	var ventana := get_window()
	ventana.size = RESOLUCIONES[indice]
	# Si no la centro, al agrandarla queda corrida y se sale de la pantalla.
	ventana.move_to_center()


func _on_boton_volver_pressed() -> void:
	Transicion.cambiar_escena(RUTA_MENU)
