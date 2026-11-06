class_name Zombie
extends CharacterBody2D
# Clase base de los zombies. Acá pongo todo lo que tienen en común (moverse, morder,
# morir, la sangre) y dejo un solo método, calcular_direccion(), para que cada tipo
# de zombie decida a dónde ir. Así no tengo un "if tipo == 0 ... else ..." por todos lados:
# cada hijo sobreescribe ese método y listo.

# El nivel la escucha. Por ahora no la usa para ganar (se gana llegando a la meta),
# pero la dejo porque me sirve si después quiero contar los zombies que maté.
signal murio

const ESCENA_SANGRE := preload("res://escenas/sangre.tscn")

@export var velocidad: float = 120.0
# Hasta que el jugador no se acerca a esta distancia el zombie se queda quieto.
# Si no, apenas arranca el nivel se me venían todos encima de una.
@export var distancia_deteccion: float = 450.0
@export var distancia_empujon: float = 24.0
# Lo que suma al puntaje cuando lo mato. Cada escena de zombie pone su valor:
# el inteligente da más porque es más difícil de esquivar.
@export var puntos_que_doy: int = 10

var jugador: Node2D
var esta_muerto: bool = false
# Una vez que me vio ya no me suelta, aunque me aleje.
var me_detecto: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var mordida: Area2D = $Mordida
@onready var sonido_muerte: AudioStreamPlayer2D = $SonidoMuerte


func _ready() -> void:
	# Al jugador lo busco por grupo y no por ruta ($../Jugador) porque así el zombie
	# funciona en cualquier nivel sin importar cómo esté armado el árbol.
	jugador = get_tree().get_first_node_in_group("jugador")
	mordida.body_entered.connect(_on_mordida_body_entered)


func _physics_process(_delta: float) -> void:
	if esta_muerto or jugador == null or jugador.esta_muerto:
		return

	if not me_detecto:
		if global_position.distance_to(jugador.global_position) < distancia_deteccion:
			me_detecto = true
		else:
			return

	# Esta es la única línea que cambia entre un zombie y otro: le pregunto al hijo
	# para dónde ir. El resto del movimiento es igual para los dos.
	var direccion := calcular_direccion()
	velocity = direccion * velocidad
	move_and_slide()

	# Giro solo si me estoy moviendo; si no, con dirección cero quedaría mirando a la derecha.
	if direccion != Vector2.ZERO:
		rotation = direccion.angle()


# La sobreescriben ZombieTonto y ZombieInteligente. Acá devuelvo cero para que,
# si alguien usara la clase base sola, el zombie simplemente se quede quieto.
func calcular_direccion() -> Vector2:
	return Vector2.ZERO


func _on_mordida_body_entered(body: Node2D) -> void:
	# La máscara de la Mordida ya es solo la capa del jugador, pero igual pregunto
	# por las dudas de que en algún momento le cambie la capa a algo.
	if esta_muerto:
		return
	if body.has_method("morir"):
		body.morir(global_position.direction_to(body.global_position))


func morir(direccion_golpe: Vector2 = Vector2.ZERO) -> void:
	if esta_muerto:
		return
	esta_muerto = true
	# Puntaje es el autoload, por eso lo puedo usar desde cualquier script sin buscarlo.
	# Si el jugador ya está muerto no sumo: puede pasar con una bala que seguía volando,
	# y el cartel de "te comieron" ya mostró (y guardó) el puntaje final.
	if jugador != null and not jugador.esta_muerto:
		Puntaje.sumar(puntos_que_doy)
	# Uso AudioStreamPlayer2D (y no el común) para que se escuche más fuerte
	# cuando el zombie muere cerca mío y más bajo si está lejos.
	sonido_muerte.play()

	if direccion_golpe == Vector2.ZERO:
		direccion_golpe = Vector2.RIGHT.rotated(randf() * TAU)

	# Apago el cuerpo y también la mordida: me pasó que el cadáver me seguía matando
	# si lo pisaba, porque el Area2D seguía prendido.
	colision.set_deferred("disabled", true)
	mordida.set_deferred("monitoring", false)

	sprite.modulate = Color(0.45, 0.2, 0.2)
	z_index = -1

	crear_sangre(direccion_golpe)

	rotation = direccion_golpe.angle()
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + direccion_golpe * distancia_empujon, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	murio.emit()


func crear_sangre(direccion_golpe: Vector2) -> void:
	var sangre := ESCENA_SANGRE.instantiate()
	get_tree().current_scene.add_child(sangre)
	sangre.global_position = global_position
	sangre.rotation = direccion_golpe.angle()
