extends GPUParticles2D
# Estallido corto de chispas. Lo uso cuando una bala pega en una pared y cuando
# agarro una caja de munición. Es one_shot: sale una vez y después me borro solo.


func _ready() -> void:
	emitting = true
	# finished avisa cuando terminaron todas las partículas; ahí borro el nodo
	# para no dejar nodos colgados en el nivel (igual que la salpicadura de la sangre).
	finished.connect(queue_free)
