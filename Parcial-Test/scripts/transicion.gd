extends CanvasLayer
# Fundido a negro entre escenas. Lo cargo como autoload (Proyecto > Configuración >
# Autoload) para que exista siempre, por encima de cualquier escena: si estuviera
# adentro de un nivel, se borraría junto con el nivel justo en el medio del fade.
# Todos los cambios de escena del juego pasan por acá en vez de llamar directo
# a change_scene_to_file, así el pasaje de un nivel a otro no es tan brusco.

# Lo que tarda en oscurecer y lo mismo en aclarar.
const DURACION_FADE := 0.4

# Mientras dura un fade no dejo empezar otro (por ejemplo, si aprieto R dos veces).
var cambiando: bool = false

@onready var negro: ColorRect = $Negro


func _ready() -> void:
	# Arranco en negro y aclaro, así la primera pantalla del juego también aparece con fade.
	negro.modulate.a = 1.0
	aclarar()


func cambiar_escena(ruta: String) -> void:
	if cambiando:
		return
	cambiando = true
	# await espera a que termine el fade antes de seguir con la línea de abajo.
	await oscurecer()
	get_tree().change_scene_to_file(ruta)
	await aclarar()
	cambiando = false


# Igual que cambiar_escena pero vuelve a cargar la misma (la uso para la R de reiniciar).
func reiniciar_escena() -> void:
	if cambiando:
		return
	cambiando = true
	await oscurecer()
	get_tree().reload_current_scene()
	await aclarar()
	cambiando = false


func oscurecer() -> void:
	# Mientras está oscuro freno los clicks, para no apretar un botón que ya se está yendo.
	negro.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(negro, "modulate:a", 1.0, DURACION_FADE)
	await tween.finished


func aclarar() -> void:
	var tween := create_tween()
	tween.tween_property(negro, "modulate:a", 0.0, DURACION_FADE)
	await tween.finished
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
