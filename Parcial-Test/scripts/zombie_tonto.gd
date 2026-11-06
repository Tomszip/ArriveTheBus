class_name ZombieTonto
extends Zombie
# El zombie tonto no piensa: va en línea recta hacia donde estoy.
# Si hay una pared en el medio se queda chocándose contra ella (move_and_slide
# lo hace resbalar un poco, pero en las esquinas queda trabado).


func calcular_direccion() -> Vector2:
	return global_position.direction_to(jugador.global_position)
