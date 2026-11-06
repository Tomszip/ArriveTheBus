extends CharacterBody2D
# La bala que dispara el jugador.
# Al principio era un Area2D, pero atravesaba las paredes: va tan rápido (20 píxeles por frame)
# que el Area2D se enteraba del choque un par de frames tarde, cuando ya estaba del otro lado.
# Con move_and_collide Godot revisa todo el camino que voy a hacer en el frame y me frena
# justo donde choco, así no hay forma de saltearme una pared.

const ESCENA_CHISPAS := preload("res://escenas/chispas.tscn")

@export var velocidad: float = 1200.0
# Si no choca con nada la borro igual a los 2 segundos, para no llenar el nivel de balas perdidas.
@export var tiempo_de_vida: float = 2.0


func _ready() -> void:
	# Un timer de un solo uso: cuando termina, la bala se borra sola.
	get_tree().create_timer(tiempo_de_vida).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	# transform.x es hacia donde apunta la bala (la rotación que le copié a la punta del arma).
	var choque := move_and_collide(transform.x * velocidad * delta)

	# Si no chocó con nada, choque es null y sigo de largo.
	if choque == null:
		return

	# No me importa si es un zombie o una pared: si sabe morir, que se muera.
	# Le paso hacia dónde iba yo para que la sangre y el empujón salgan para ese lado.
	var otro := choque.get_collider()
	if otro.has_method("morir"):
		otro.morir(transform.x)
	else:
		# Si le pegué a una pared tiro chispas. get_normal() apunta "saliendo" de la
		# pared, así que las chispas rebotan para el lado de donde vino la bala.
		var chispas := ESCENA_CHISPAS.instantiate()
		get_tree().current_scene.add_child(chispas)
		chispas.global_position = choque.get_position()
		chispas.rotation = choque.get_normal().angle()
	queue_free()
