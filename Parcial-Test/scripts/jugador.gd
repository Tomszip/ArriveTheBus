extends CharacterBody2D

# La emito cuando me matan, así el nivel se entera y muestra el cartel de "perdiste".
# Prefiero una señal antes que buscar el nivel desde acá, así el jugador no depende de nadie.
signal murio
# La emito cada vez que cambian mis balas. El nivel la conecta con el HUD para el contador.
signal municion_cambio(en_cargador: int, en_reserva: int, recargando: bool)

# Uso preload porque así la escena de la bala se carga una sola vez al arrancar
# y no cada vez que disparo.
const ESCENA_BALA := preload("res://escenas/bala.tscn")
const ESCENA_SANGRE := preload("res://escenas/sangre.tscn")
# Las balas mías tienen que chocar con las paredes (capa 1 = valor 1) y con los
# zombies (capa 3 = valor 4). Sumo los dos valores para armar la máscara.
const MASCARA_BALA := 1 | 4

# Los dejo con @export para poder probar valores desde el inspector sin tocar el código.
@export var velocidad: float = 300.0
@export var tiempo_entre_disparos: float = 0.2
# Cuántos píxeles salgo despedido cuando me matan (queda más lindo que caer en el lugar).
@export var distancia_empujon: float = 24.0
# Munición: lo que entra en el cargador, con cuántas balas de repuesto arranco
# y cuánto tardo en recargar.
@export var tamano_cargador: int = 12
@export var reserva_inicial: int = 12
@export var tiempo_recarga: float = 1.2

var esta_muerto: bool = false
# Lo voy restando con delta; cuando llega a 0 puedo volver a disparar.
var tiempo_para_disparar: float = 0.0
var balas_en_cargador: int = 0
var balas_en_reserva: int = 0
# Igual que tiempo_para_disparar: si es mayor a 0 estoy recargando y no puedo disparar.
var tiempo_recargando: float = 0.0

# Los pido con @onready porque si los busco antes del _ready() los hijos todavía no existen
# y me da null.
@onready var punta_arma: Marker2D = $PuntaArma
@onready var fogonazo: GPUParticles2D = $PuntaArma/Fogonazo
@onready var sprite: Sprite2D = $Sprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var sonido_disparo: AudioStreamPlayer = $SonidoDisparo
@onready var sonido_mordida: AudioStreamPlayer = $SonidoMordida


func _ready() -> void:
	# Arranco cada nivel con el cargador lleno.
	balas_en_cargador = tamano_cargador
	balas_en_reserva = reserva_inicial


func _physics_process(delta: float) -> void:
	# Si estoy muerto no hago nada más: ni me muevo, ni apunto, ni disparo.
	if esta_muerto:
		return

	# get_vector ya me devuelve la dirección normalizada, así en diagonal no voy más rápido.
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	velocity = direccion * velocidad
	# move_and_slide hace que me deslice contra las paredes en vez de quedarme pegado.
	move_and_slide()

	# Uso la posición GLOBAL del mouse porque la cámara se mueve conmigo; la de la
	# pantalla no me serviría. Los sprites de Kenney miran a la derecha, así que
	# look_at (que apunta el eje X) me deja mirando justo al mouse.
	look_at(get_global_mouse_position())

	tiempo_para_disparar -= delta

	# Mientras recargo me puedo mover pero no disparar.
	if tiempo_recargando > 0.0:
		tiempo_recargando -= delta
		if tiempo_recargando <= 0.0:
			terminar_recarga()
	elif Input.is_action_just_pressed("recargar"):
		empezar_recarga()
	# is_action_pressed (y no just_pressed) para poder mantener el click y disparar seguido.
	elif Input.is_action_pressed("disparar") and tiempo_para_disparar <= 0.0:
		if balas_en_cargador > 0:
			disparar()
		else:
			# Me quedé sin balas en el cargador pero junté más del piso: recargo solo.
			empezar_recarga()


func disparar() -> void:
	tiempo_para_disparar = tiempo_entre_disparos
	balas_en_cargador -= 1
	avisar_municion()
	# El sonido dura más que el tiempo entre disparos; por eso le puse max_polyphony
	# en la escena, así un disparo no corta al anterior.
	sonido_disparo.play()
	# Las partículas del fogonazo son one_shot: con restart() las vuelvo a tirar en cada tiro.
	fogonazo.restart()

	var bala := ESCENA_BALA.instantiate()
	bala.collision_mask = MASCARA_BALA
	# La agrego al nivel y no como hija mía, porque si no la bala se movería y giraría conmigo.
	get_tree().current_scene.add_child(bala)
	# La pongo después del add_child, con la misma posición y rotación que la punta del arma.
	bala.global_transform = punta_arma.global_transform

	# Si vacié el cargador recargo solo, así no tengo que acordarme de apretar R.
	if balas_en_cargador == 0:
		empezar_recarga()


func empezar_recarga() -> void:
	# No tiene sentido recargar con el cargador lleno o sin balas de repuesto.
	if balas_en_cargador == tamano_cargador or balas_en_reserva == 0:
		return
	tiempo_recargando = tiempo_recarga
	avisar_municion()


func terminar_recarga() -> void:
	# Paso del repuesto al cargador solo las que faltan (o las que me quedan, si son menos).
	var faltan := tamano_cargador - balas_en_cargador
	var pongo := mini(faltan, balas_en_reserva)
	balas_en_cargador += pongo
	balas_en_reserva -= pongo
	avisar_municion()


# La llama la caja de munición del piso cuando paso por arriba.
func juntar_municion(cantidad: int) -> void:
	balas_en_reserva += cantidad
	avisar_municion()


# Junto en un solo lugar el emit, así no me olvido de ningún dato en cada llamada.
func avisar_municion() -> void:
	municion_cambio.emit(balas_en_cargador, balas_en_reserva, tiempo_recargando > 0.0)


# La llaman los zombies cuando me muerden. Se llama igual que la de los zombies
# a propósito: así la bala y la mordida no necesitan saber a quién le pegan.
func morir(direccion_golpe: Vector2 = Vector2.ZERO) -> void:
	# Por si me muerden dos zombies en el mismo frame, que no me muera dos veces.
	if esta_muerto:
		return
	esta_muerto = true
	sonido_mordida.play()

	# Si no sé de dónde vino el golpe, elijo una dirección cualquiera.
	if direccion_golpe == Vector2.ZERO:
		direccion_golpe = Vector2.RIGHT.rotated(randf() * TAU)

	# set_deferred porque Godot no deja apagar una colisión en el medio de una señal de física.
	colision.set_deferred("disabled", true)

	# Me oscurezco y me dibujo por debajo de los vivos para que se note que soy un cadáver.
	sprite.modulate = Color(0.45, 0.2, 0.2)
	z_index = -1

	var sangre := ESCENA_SANGRE.instantiate()
	get_tree().current_scene.add_child(sangre)
	sangre.global_position = global_position
	sangre.rotation = direccion_golpe.angle()

	# Caigo mirando para donde me empujaron y con un tween me deslizo un poquito.
	rotation = direccion_golpe.angle()
	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + direccion_golpe * distancia_empujon, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	murio.emit()
