# Arrive The Bus

Juego top-down de disparos hecho en Godot 4.7 para el parcial de Videojuegos.
Perdiste el último colectivo de la noche y la ciudad está llena de zombies: tenés que llegar
caminando hasta la parada antes de que te coman.

## Cómo correrlo

1. Abrir Godot 4.7.
2. En el gestor de proyectos, **Importar** y elegir el `project.godot` de esta carpeta.
3. Apretar **F5** (o el botón de Play). Arranca en el menú principal; **Jugar** empieza siempre
   desde el Nivel 1 y al Nivel 2 se llega pasando por la puerta.

## Controles

| Tecla | Acción |
|---|---|
| W A S D | Moverse |
| Mouse | Apuntar |
| Click izquierdo | Disparar (se puede mantener apretado) |
| R | Recargar el arma. Cuando te comen (o al final), reinicia el nivel |
| Esc | Volver al menú |

## Cómo se juega

Cada nivel tiene un punto de salida (A, donde arranca el personaje) y una **puerta de salida**
(B, con el cartel "SALIDA" y una luz naranja que titila). Al llegar a la puerta se abre y se pasa
al nivel siguiente con un fundido a negro. Si un zombie te toca, perdés y podés reintentar con R.
El Nivel 2 es el último: al terminarlo llegás a la parada.

**Puntaje:** cada zombie tonto suma 10, cada inteligente 25 y llegar a la puerta suma 100.
El puntaje se arrastra del Nivel 1 al 2 y se ve en el panel de arriba a la derecha. Si te comen y reiniciás
con R, el puntaje vuelve al que tenías al empezar ese nivel. Desde el menú arranca en 0.

**Niveles:** Nivel 1 **El Conventillo** (una casa vieja de cuatro piezas) y Nivel 2
**Barrio Farol Roto** (un laberinto de calles y casas). Se juegan en orden: Jugar arranca siempre
en el Nivel 1.

**HUD:** arriba hay tres paneles con el mismo estilo que el menú (fondo gris, borde naranja):
el nivel a la izquierda, el cargador en el medio (una balita dorada por bala, se ponen grises
al disparar, más la reserva) y el puntaje a la derecha.

**Dificultad:** el Nivel 1 tiene 4 zombies; el Nivel 2 tiene 12 y además son un 15 % más rápidos.

**Munición:** la pistola tiene un cargador de 12 balas y arrancás cada nivel con 12 de reserva.
En el panel del medio se ven las balas del cargador y la reserva. Cuando el cargador se
vacía recarga sola (tarda 1,2 s); también se puede recargar antes con R. En el piso hay cajas de
munición (2 en el Nivel 1 y 4 en el Nivel 2) que dan 12 balas cada una: algunas están cerca de
zombies, así que hay que pensar si vale la pena ir a buscarlas.

**Récords:** cada partida (desde que apretás Jugar hasta que volvés al menú) ocupa **una sola
fila** en la tabla de **Mejores puntajes** del menú, con el mejor resultado que lograste en ella:
si te comen varias veces y reintentás con R, no se repite. Se guardan los 5 mejores en un archivo, así que siguen ahí aunque
cierres el juego.

**Efectos:** fogonazo al disparar, chispas cuando la bala pega en una pared o cuando agarrás una
caja, brillo en las cajas y la salpicadura de sangre al morir.

Hay dos tipos de zombie:

- **Verde (tonto):** va en línea recta hacia vos. Si hay una pared en el medio, se queda trabado
  contra ella.
- **Rojo (inteligente):** te sigue todo el tiempo y rodea las paredes buscando el camino.

Los zombies no se mueven hasta que te acercás a una cierta distancia, para que no se te vengan
todos encima apenas arranca el nivel.

## Paleta

La idea es una calle de noche iluminada por faroles de sodio. No cambié los dibujos de
los tiles: a cada capa del nivel le puse un `modulate` (un color que multiplica al de la imagen).

| Qué | Color | Por qué |
|---|---|---|
| Fondo y menús | gris casi negro `#1C1C1F` | la noche |
| Piso (calle y casas) | tinte azul frío | que se sienta de noche |
| Paredes | tinte naranja cálido | como si les pegara la luz del farol |
| Puerta de salida y bordes de los botones | naranja `#C76B29` | el farol / la parada; es lo que hay que buscar |
| Zombie tonto / inteligente | verde / rojo | que se distingan de un vistazo |
| Botón apretado y sangre | rojo sangre | |

## Dónde está cada requisito

| Requisito | Dónde está |
|---|---|
| Menú con Jugar (arranca siempre en el Nivel 1), Opciones y Salir | `escenas/menu_principal.tscn` + `scripts/menu_principal.gd` |
| Opciones: barra de volumen y selector de resolución | `escenas/opciones.tscn` + `scripts/opciones.gd` |
| Personaje con pistola | `escenas/jugador.tscn` + `scripts/jugador.gd` (la bala en `escenas/bala.tscn` + `scripts/bala.gd`) |
| Zombie tonto (va directo) | `escenas/zombie_tonto.tscn` + `scripts/zombie_tonto.gd` |
| Zombie inteligente (pathfinding) | `escenas/zombie_inteligente.tscn` + `scripts/zombie_inteligente.gd` |
| Herencia con `class_name` | `scripts/zombie.gd` (clase base `Zombie`) |
| Ganar yendo de A a B y pasar de nivel | `scripts/nivel.gd` (lo usan los dos niveles) |
| Puerta para pasar de nivel | `escenas/puerta.tscn` + `scripts/puerta.gd` |
| Fade in / fade out entre escenas (CanvasLayer) | `escenas/transicion.tscn` + `scripts/transicion.gd` (autoload `Transicion`) |
| Puntaje con autoload | `scripts/puntaje.gd` (autoload `Puntaje`), se muestra en `escenas/hud.tscn` |
| Munición: cargador, reserva y recarga | `scripts/jugador.gd` (señal `municion_cambio`), contador en `escenas/hud.tscn` + `scripts/hud.gd` |
| Munición en el piso | `escenas/caja_municion.tscn` + `scripts/caja_municion.gd` |
| Efectos de partículas | `escenas/chispas.tscn` + `scripts/chispas.gd`, `Fogonazo` en `escenas/jugador.tscn`, `Brillo` en la caja, `escenas/sangre.tscn` |
| Tabla de récords persistente | `scripts/puntaje.gd` (guarda en `user://records.cfg`), se muestra en `escenas/menu_principal.tscn` |
| Dificultad en aumento | `@export multiplicador_velocidad` en `scripts/nivel.gd` (Nivel 2 = 1.15) y más zombies en `nivel_2.tscn` |
| Niveles | `escenas/niveles/nivel_1.tscn` y `escenas/niveles/nivel_2.tscn` |
| Carteles de ganar / perder, nombre del nivel y puntaje | `escenas/hud.tscn` + `scripts/hud.gd` |
| Música de fondo | `escenas/musica.tscn` + `scripts/musica.gd` |

## Autoloads

Están en **Proyecto > Configuración del proyecto > Globales (Autoload)**. Un autoload es un nodo
que Godot crea al arrancar y que no se borra al cambiar de escena, por eso sirve para guardar
cosas que tienen que pasar de un nivel a otro.

- `Puntaje` (`scripts/puntaje.gd`): guarda los puntos y avisa con la señal `puntaje_cambio`.
  También carga y guarda la tabla de récords con un `ConfigFile` en `user://records.cfg`
  (en Windows: `%APPDATA%\Godot\app_userdata\Arrive The Bus\`). Para borrar los récords,
  alcanza con borrar ese archivo.
- `Transicion` (`escenas/transicion.tscn`): un `CanvasLayer` en la capa 100 (arriba de todo) con un
  `ColorRect` negro. Para cambiar de escena se llama a `Transicion.cambiar_escena(ruta)`: oscurece
  con un `Tween`, cambia la escena y vuelve a aclarar.

Las carpetas son `escenas/` para las escenas, `scripts/` para el código y `assets/` para
imágenes, tiles, sonidos y el tema de los menús.

## Cómo funciona la herencia de los zombies

Los dos zombies hacen casi lo mismo: esperan a que te acerques, se mueven, giran hacia donde
van, te muerden y se mueren cuando les pegás un tiro. Lo único que cambia es **hacia dónde
deciden moverse**.

Por eso armé una clase base, `Zombie` (`scripts/zombie.gd`), con `class_name Zombie`, que tiene
todo lo común. En el `_physics_process` llama a un solo método:

```gdscript
var direccion := calcular_direccion()
velocity = direccion * velocidad
move_and_slide()
```

En la clase base `calcular_direccion()` devuelve `Vector2.ZERO` (el zombie se queda quieto).
Cada hijo hereda con `extends Zombie` y sobreescribe solamente ese método:

- `ZombieTonto` (`extends Zombie`): devuelve la dirección en línea recta hacia el jugador.
- `ZombieInteligente` (`extends Zombie`): en cada frame le pasa la posición del jugador a su
  `NavigationAgent2D` y devuelve la dirección hacia el próximo punto del camino. El camino sale
  del `NavigationRegion2D` de cada nivel, que tiene marcadas las zonas por donde se puede caminar.

```
        Zombie  (zombie.gd)
       /       \
ZombieTonto   ZombieInteligente
```

**Por qué así y no con una variable de tipo:** si hubiera hecho un solo script con
`var tipo` y un `if tipo == TONTO ... else ...`, cada zombie nuevo me obligaría a meter otro `if`
en el mismo archivo. Con herencia, el código común está en un solo lugar (si arreglo algo en
`morir()` se arregla para los dos) y para agregar un tercer tipo de zombie alcanza con crear otro
script que haga `extends Zombie` y escriba su propio `calcular_direccion()`.

## Créditos

- Sprites del personaje, zombies y tiles: [Kenney – Top-down Shooter](https://kenney.nl/assets/top-down-shooter) (licencia CC0).
- Sonidos de mordida y muerte de zombie: [Kenney – Impact Sounds](https://kenney.nl/assets/impact-sounds) (licencia CC0).
- Sonido del disparo y música de fondo: hechos por nosotros.
