extends Node2D
# Script que comparten todos los niveles. Se encarga de ganar (llegar a la Puerta),
# perder (que me muerdan), la dificultad y pasar al nivel siguiente.

# Lo hice @export para que cada nivel diga cuál le sigue desde el inspector, en vez
# de tener un script distinto por nivel. Si queda vacío, es el último nivel.
@export_file("*.tscn") var siguiente_nivel: String = ""
# El nombre que muestra el HUD arriba a la izquierda.
@export var nombre_nivel: String = ""
# Con esto subo la dificultad de un nivel a otro: multiplico la velocidad de todos
# los zombies del nivel. Así no tengo que hacer escenas de zombie "rápidas" aparte.
# Además el Nivel 2 tiene muchos más zombies que el 1.
@export var multiplicador_velocidad: float = 1.0

# Segundos que muestro el cartel de "nivel superado" antes de cambiar de escena.
const ESPERA_CAMBIO_NIVEL := 1.5
const RUTA_MENU := "res://escenas/menu_principal.tscn"
# Premio por llegar a la puerta, así pasar de nivel también suma.
const PUNTOS_POR_LLEGAR := 100

# Para que no pueda ganar y perder a la vez (por ejemplo, si me muerden justo en la puerta).
var termino: bool = false
# La R también recarga el arma, así que solo reinicio el nivel cuando ya está el cartel
# de "te comieron" o el del final. Si no, al querer recargar se me reiniciaba todo.
var puedo_reiniciar: bool = false

@onready var jugador: CharacterBody2D = $Jugador
@onready var hud: CanvasLayer = $HUD
@onready var puerta: Area2D = $Puerta


func _ready() -> void:
	# Me anoto con cuántos puntos llegué, para volver a ese valor si reinicio con R.
	Puntaje.guardar_inicio_de_nivel()
	hud.mostrar_nombre_nivel(nombre_nivel)

	# Los hijos hacen su _ready antes que el padre, así que acá los zombies ya existen.
	for zombie in get_tree().get_nodes_in_group("zombies"):
		zombie.velocidad *= multiplicador_velocidad

	# El jugador no conoce al HUD: yo los conecto acá y le pido que avise una vez
	# para que el contador arranque con el valor correcto.
	hud.preparar_cargador(jugador.tamano_cargador)
	jugador.municion_cambio.connect(hud.actualizar_municion)
	jugador.avisar_municion()

	jugador.murio.connect(_on_jugador_murio)
	puerta.body_entered.connect(_on_puerta_body_entered)


func _unhandled_input(event: InputEvent) -> void:
	# Si ya hay un fade en marcha ignoro las teclas, así no mezclo dos cambios de escena.
	if Transicion.cambiando:
		return

	if event.is_action_pressed("reiniciar") and puedo_reiniciar:
		Puntaje.volver_al_inicio_de_nivel()
		Transicion.reiniciar_escena()
	elif event.is_action_pressed("ui_cancel"):
		# ui_cancel ya viene en Godot y es la tecla Esc. Vuelvo al menú en vez de
		# cerrar el juego, que para eso está el botón Salir.
		Transicion.cambiar_escena(RUTA_MENU)


func _on_jugador_murio() -> void:
	if termino:
		return
	termino = true
	puedo_reiniciar = true
	# La partida terminó: la anoto en la tabla de récords (se guarda en un archivo).
	Puntaje.guardar_record(nombre_nivel.get_slice(":", 0))
	hud.mostrar_mensaje("TE COMIERON", "Puntaje: %d\nR para intentar de nuevo  ·  Esc para volver al menú" % Puntaje.puntos)


func _on_puerta_body_entered(_body: Node2D) -> void:
	# No pregunto si el body es el jugador porque la máscara de la Puerta es solo
	# la capa del jugador, así que nadie más la puede activar.
	if termino:
		return
	termino = true

	# Freno a todos los zombies que quedan para que no me maten mientras está el cartel.
	get_tree().call_group("zombies", "set_physics_process", false)
	puerta.abrir()
	Puntaje.sumar(PUNTOS_POR_LLEGAR)

	if siguiente_nivel == "":
		puedo_reiniciar = true
		Puntaje.guardar_record("¡Parada!")
		hud.mostrar_mensaje("¡LLEGASTE A LA PARADA!", "Puntaje final: %d\nR para jugar de nuevo  ·  Esc para volver al menú" % Puntaje.puntos)
		return

	hud.mostrar_mensaje("NIVEL SUPERADO", "+%d puntos  ·  Siguiente nivel..." % PUNTOS_POR_LLEGAR)
	# await espera el timer sin congelar el juego, así el cartel se llega a ver.
	await get_tree().create_timer(ESPERA_CAMBIO_NIVEL).timeout
	# Si mientras tanto apreté Esc, Transicion ya está ocupada y esto no hace nada.
	Transicion.cambiar_escena(siguiente_nivel)
