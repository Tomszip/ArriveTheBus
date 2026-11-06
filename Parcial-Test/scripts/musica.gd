extends AudioStreamPlayer
# Música de fondo. La armé como escena aparte para meterla igual en el menú,
# en Opciones y en los niveles, sin repetir este código en cada script.


func _ready() -> void:
	# El .wav no viene marcado para repetirse, así que cuando termina la vuelvo a arrancar.
	# Lo hice así en vez de tocar las opciones de importación para que se vea en el código.
	finished.connect(play)
	play()
