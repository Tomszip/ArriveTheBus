extends Area2D
# Caja de balas tirada en el piso. Cuando paso por arriba me da balas de repuesto
# y desaparece. Es un Area2D con máscara = jugador, igual que la Puerta.

const ESCENA_CHISPAS := preload("res://escenas/chispas.tscn")

# Cuántas balas me da. Lo dejo @export por si quiero poner cajas más grandes en algún nivel.
@export var cantidad: int = 12

@onready var dibujo: Node2D = $Dibujo


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# La caja "late" agrandándose y achicándose para que se note que se puede agarrar.
	var tween := create_tween().set_loops()
	tween.tween_property(dibujo, "scale", Vector2(1.15, 1.15), 0.5)
	tween.tween_property(dibujo, "scale", Vector2(1.0, 1.0), 0.5)


func _on_body_entered(body: Node2D) -> void:
	# Mismo truco que con morir(): no pregunto si es el jugador, pregunto si sabe juntar balas.
	if not body.has_method("juntar_municion"):
		return
	body.juntar_municion(cantidad)

	# Un estallido de chispas donde estaba la caja, para que se note que la agarré.
	var chispas := ESCENA_CHISPAS.instantiate()
	get_tree().current_scene.add_child(chispas)
	chispas.global_position = global_position
	# queue_free y no free, porque estoy adentro de una señal de física.
	queue_free()
