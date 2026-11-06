class_name ZombieInteligente
extends Zombie
# El zombie inteligente usa el NavigationAgent2D para buscar el camino más corto
# hasta mí esquivando las paredes. La navegación sale del NavigationRegion2D del nivel.

@onready var agente: NavigationAgent2D = $NavigationAgent2D


func calcular_direccion() -> Vector2:
	# Le actualizo el destino en CADA frame porque yo me muevo todo el tiempo;
	# si se lo diera una sola vez, iría a buscarme a donde estaba antes.
	agente.target_position = jugador.global_position

	# Cuando ya está pegado a mí el agente da el camino por terminado,
	# así que en ese caso voy directo para no quedarme quieto al lado del jugador.
	if agente.is_navigation_finished():
		return global_position.direction_to(jugador.global_position)

	# get_next_path_position me da el próximo punto del camino (la próxima esquina),
	# no el destino final. Voy hacia ese punto y el agente me va dando el siguiente.
	return global_position.direction_to(agente.get_next_path_position())
