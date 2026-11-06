extends Node
# Puntaje del jugador. Es un autoload porque los niveles se borran y se vuelven a
# crear en cada cambio de escena: si el puntaje viviera en el nivel, al pasar al
# Nivel 2 arrancaría de cero. El autoload queda vivo todo el juego.

# También guarda la tabla de récords en un archivo, para que no se pierda al cerrar el juego.

# La escucha el HUD para actualizar el número sin tener que preguntar en cada frame.
signal puntaje_cambio(puntos: int)

# user:// es una carpeta que Godot le da a cada juego para guardar datos del jugador
# (en Windows queda en AppData). No uso res:// porque cuando el juego está exportado
# esa carpeta es de solo lectura.
const RUTA_RECORDS := "user://records.cfg"
const CANTIDAD_RECORDS := 5

var puntos: int = 0
# Me guardo con cuántos puntos empecé el nivel. Si me matan y aprieto R, vuelvo a
# este valor; si no, podría farmear puntos muriendo y reiniciando.
var puntos_al_empezar_nivel: int = 0
# Cada récord es un diccionario {"id", "puntos", "llego_a", "fecha"}, ordenados de mayor a menor.
var records: Array = []
# Número que identifica la partida actual (cambia cada vez que aprieto Jugar).
# Lo guardo en el récord para que, si muero varias veces en la misma partida y
# reintento con R, se actualice la misma fila en vez de agregar una nueva cada vez.
var id_partida: int = 0


func _ready() -> void:
	# Como soy autoload, esto corre una sola vez al abrir el juego.
	cargar_records()


func sumar(cantidad: int) -> void:
	puntos += cantidad
	puntaje_cambio.emit(puntos)


# La llama el menú cuando arranco una partida nueva.
func reiniciar() -> void:
	puntos = 0
	puntos_al_empezar_nivel = 0
	# Uso la hora actual en milisegundos como número de partida: no se repite nunca.
	id_partida = int(Time.get_unix_time_from_system() * 1000)
	puntaje_cambio.emit(puntos)


# La llama cada nivel en su _ready().
func guardar_inicio_de_nivel() -> void:
	puntos_al_empezar_nivel = puntos


# La llama el nivel antes de reiniciarse con R.
func volver_al_inicio_de_nivel() -> void:
	puntos = puntos_al_empezar_nivel
	puntaje_cambio.emit(puntos)


# --- Tabla de récords ---------------------------------------------------------------
# Uso ConfigFile (un archivo de texto con secciones y claves, tipo .ini) porque Godot
# ya sabe guardar ahí arrays y diccionarios sin que yo tenga que armar el formato.

func cargar_records() -> void:
	var archivo := ConfigFile.new()
	# La primera vez que se juega el archivo no existe y load() da error: en ese caso
	# me quedo con la lista vacía y listo.
	if archivo.load(RUTA_RECORDS) == OK:
		records = archivo.get_value("records", "lista", [])


# La llama el nivel cuando me comen o llego a la parada.
# llego_a es hasta dónde llegué, por ejemplo "Nivel 2" o "¡Parada!".
func guardar_record(llego_a: String) -> void:
	# Una partida con 0 puntos no la anoto, no tiene gracia en la tabla.
	if puntos <= 0:
		return

	var fecha := Time.get_date_dict_from_system()
	var texto_fecha := "%02d/%02d/%d" % [fecha.day, fecha.month, fecha.year]

	# Me fijo si esta partida ya tiene su fila (porque ya me comieron antes y reintenté).
	var record_de_esta_partida := buscar_record_de_la_partida()
	if record_de_esta_partida.is_empty():
		records.append({
			"id": id_partida,
			"puntos": puntos,
			"llego_a": llego_a,
			"fecha": texto_fecha,
		})
	elif puntos > record_de_esta_partida["puntos"]:
		# Como el diccionario está adentro del array, al cambiarlo acá cambia en la lista.
		record_de_esta_partida["puntos"] = puntos
		record_de_esta_partida["llego_a"] = llego_a
		record_de_esta_partida["fecha"] = texto_fecha
	else:
		# Esta vez me fue igual o peor que antes en la misma partida: no cambio nada.
		return
	# Ordeno de mayor a menor y me quedo con los mejores.
	records.sort_custom(es_mayor)
	if records.size() > CANTIDAD_RECORDS:
		records.resize(CANTIDAD_RECORDS)

	var archivo := ConfigFile.new()
	archivo.set_value("records", "lista", records)
	archivo.save(RUTA_RECORDS)


# Devuelve la fila de la partida actual, o un diccionario vacío si todavía no tiene.
func buscar_record_de_la_partida() -> Dictionary:
	for record in records:
		# Los récords viejos no tenían "id"; get() me deja poner un valor por defecto.
		if record.get("id", -1) == id_partida:
			return record
	return {}


# sort_custom necesita una función que me diga si "a" va antes que "b".
func es_mayor(a: Dictionary, b: Dictionary) -> bool:
	return a["puntos"] > b["puntos"]
