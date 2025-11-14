# Puzle_NuncaCuatro.gd
extends Control

signal nivel_completado
signal puzle_cerrado

# --- Rutas a Nodos ---
@onready var cuadricula_node = $LayoutPrincipal/CenterContainer/PuzzleLayout/Cuadricula
@onready var boton_comprobar_node = $LayoutPrincipal/CenterContainer/PuzzleLayout/ButtonLayout/BotonComprobar
@onready var boton_salir_node = $LayoutPrincipal/CenterContainer/PuzzleLayout/ButtonLayout/BotonSalir
@onready var panel_capi = $LayoutPrincipal/PanelCapi
@onready var label_mensaje = $LayoutPrincipal/PanelCapi/LabelMensaje
@onready var capi_anim = $LayoutPrincipal/PanelCapi/CapiAnim

# --- Variables del Juego ---
var grid_state = []
@export var grid_size: int = 12 

@export var tex_vacia: Texture2D
@export var tex_circulo: Texture2D
@export var tex_cruz: Texture2D
@export var tex_bloqueada: Texture2D

const VACIO = 0
const CIRCULO = 1
const CRUZ = 2
const BLOQUEADO = 3 # (No lo usamos en el generador, pero lo mantenemos)

# --- Funciones del Juego ---

func _ready():
	# Inicializa el generador de números aleatorios
	randomize()

	# 1. Ajusta la Cuadricula al nuevo tamaño
	cuadricula_node.columns = grid_size
	
	# 2. Inicializa el estado lógico (todo vacío)
	grid_state.resize(grid_size)
	for r in range(grid_size):
		grid_state[r] = []
		grid_state[r].resize(grid_size)
		grid_state[r].fill(VACIO)

	# 3. Genera la SOLUCIÓN COMPLETA en 'grid_state'
	generar_solucion()
	
	# 4. ¡NUEVO PASO! "Perforamos" la solución para crear el PUZLE
	perforar_puzle()

	# 5. Crea los botones dinámicamente
	# Este bucle ahora creará botones clicables (VACIO)
	# y botones desactivados (CIRCULO o CRUZ, que son las pistas)
	for r in range(grid_size):
		for c in range(grid_size):
			var boton = TextureButton.new()
			var tipo_casilla = grid_state[r][c]
			
			if tipo_casilla == VACIO:
				# ¡ESTO ES AHORA EL PUZLE JUGABLE!
				boton.pressed.connect(_on_casilla_pressed.bind(r, c))
				_actualizar_textura(boton, VACIO)
			else:
				# ¡ESTAS SON LAS PISTAS!
				boton.disabled = true
				_actualizar_textura(boton, tipo_casilla)
				boton.modulate = Color(0.7, 0.7, 0.7)
			
			cuadricula_node.add_child(boton)
			
	# Conecta los botones de Comprobar y Salir
	boton_comprobar_node.pressed.connect(_on_boton_comprobar_pressed)
	boton_salir_node.pressed.connect(_on_boton_salir_pressed)
	
	# Asegura que Capi empiece en la animación de reposo
	capi_anim.play("idle")
	
	# Muestra el mensaje de bienvenida de Capi
	mostrar_mensaje.call_deferred("¡Rellena las casillas vacías! ¡Pero ojo, nunca 4 símbolos iguales seguidos!")


# ----------------------------------------------
# ¡NUEVA FUNCIÓN: EL "PERFORADOR" (PUZZLER)!
# ----------------------------------------------
# Quita piezas de la solución para crear el puzle
func perforar_puzle():
	var total_celdas = grid_size * grid_size
	var num_a_quitar = 0
	
	# Define la dificultad basándose en el tamaño
	match grid_size:
		5: # Fácil (5x5)
			# Quitamos ~40% de las piezas
			num_a_quitar = int(total_celdas * 0.40)
		8: # Medio (8x8)
			# Quitamos ~60% de las piezas
			num_a_quitar = int(total_celdas * 0.60)
		12: # Difícil (12x12)
			# Quitamos ~75% de las piezas
			num_a_quitar = int(total_celdas * 0.75)
	
	var contador = 0
	# Sigue haciendo agujeros hasta que alcancemos el número deseado
	while contador < num_a_quitar:
		var r = randi() % grid_size # Elige una fila aleatoria
		var c = randi() % grid_size # Elige una columna aleatoria
		
		# Si la casilla no está ya vacía, la vaciamos
		if grid_state[r][c] != VACIO:
			grid_state[r][c] = VACIO
			contador += 1
			
# ----------------------------------------------
# FUNCIÓN SOLUCIONADOR (SOLVER)
# ----------------------------------------------
# (Sin cambios respecto a la versión anterior)
func generar_solucion():
	for r in range(grid_size):
		for c in range(grid_size):
			if grid_state[r][c] == VACIO:
				
				var opciones = [CIRCULO, CRUZ]
				opciones.shuffle()
				
				for tipo in opciones:
					grid_state[r][c] = tipo
					
					if _es_movimiento_valido(r, c):
						if generar_solucion():
							return true
					
					grid_state[r][c] = VACIO
				
				return false
				
	return true

# ----------------------------------------------
# FUNCIÓN VALIDADOR RÁPIDO
# ----------------------------------------------
# (Sin cambios respecto a la versión anterior)
func _es_movimiento_valido(r, c):
	var tipo_actual = grid_state[r][c]
	if tipo_actual == VACIO:
		return true

	# Comprobar Fila (Horizontal)
	var contador = 0
	for i in range(grid_size):
		if grid_state[r][i] == tipo_actual:
			contador += 1
			if contador >= 4: return false
		else:
			contador = 0
	
	# Comprobar Columna (Vertical)
	contador = 0
	for i in range(grid_size):
		if grid_state[i][c] == tipo_actual:
			contador += 1
			if contador >= 4: return false
		else:
			contador = 0
	
	# Comprobar Diagonales
	contador = 0
	for i in range(-grid_size + 1, grid_size):
		for j in range(grid_size):
			var r_diag = j
			var c_diag = i + j
			if c_diag >= 0 and c_diag < grid_size:
				if grid_state[r_diag][c_diag] == tipo_actual:
					contador += 1
					if contador >= 4: return false
				else:
					contador = 0
		contador = 0

	contador = 0
	for i in range(-grid_size + 1, grid_size):
		for j in range(grid_size):
			var r_diag = j
			var c_diag = grid_size - 1 - (i + j)
			if c_diag >= 0 and c_diag < grid_size:
				if grid_state[r_diag][c_diag] == tipo_actual:
					contador += 1
					if contador >= 4: return false
				else:
					contador = 0
		contador = 0

	return true

# --- (El resto de funciones no necesitan cambios) ---

# Muestra un mensaje en el panel de Capi
func mostrar_mensaje(texto):
	label_mensaje.text = texto
	panel_capi.visible = true
	
	capi_anim.play("talking")
	
	var duracion_habla = max(1.5, texto.length() * 0.05)
	await get_tree().create_timer(duracion_habla).timeout
	
	capi_anim.play("idle")


# Se llama CADA VEZ que el jugador pulsa una casilla VACÍA
func _on_casilla_pressed(r, c):
	grid_state[r][c] = (grid_state[r][c] + 1) % 3
	var i = (r * grid_size) + c
	var boton = cuadricula_node.get_child(i)
	_actualizar_textura(boton, grid_state[r][c])


# Función ayudante para poner la textura correcta
func _actualizar_textura(boton, tipo):
	match tipo:
		VACIO:
			boton.texture_normal = tex_vacia
		CIRCULO:
			boton.texture_normal = tex_circulo
		CRUZ:
			boton.texture_normal = tex_cruz
		BLOQUEADO:
			boton.texture_normal = tex_bloqueada

# Función "Juez" - Se llama al pulsar "Comprobar"
func _on_boton_comprobar_pressed():
	print("Comprobando victoria...")
	
	var resultado = _comprobar_victoria()
	var es_valido = resultado[0]
	var mensaje_error = resultado[1]
	
	if es_valido == true:
		var mensaje_victoria = "¡Genial! ¡Lo has conseguido! Has entendido la lógica."
		print(mensaje_victoria)
		
		await mostrar_mensaje(mensaje_victoria)
		await get_tree().create_timer(1.0).timeout
		
		nivel_completado.emit()
	else:
		print("Aún no... Error: %s" % mensaje_error)
		await mostrar_mensaje(mensaje_error)


# Función "Botón de Salida"
func _on_boton_salir_pressed():
	print("¡CLIC EN SALIR! - Emitiendo señal...")
	puzle_cerrado.emit()

# ----------------------------------------------
# Función de Lógica de Victoria (El "Libro de Reglas")
# ----------------------------------------------
# (Sin cambios respecto a la versión anterior)
func _comprobar_victoria():
	
	# Comprobación 1: ¿Está el tablero LLENO?
	for r in range(grid_size):
		for c in range(grid_size):
			if grid_state[r][c] == VACIO:
				return [false, "¡Oh! Parece que aún te quedan casillas vacías por rellenar."]

	# Comprobación 2: Regla "Nunca Cuatro"
	for r in range(grid_size):
		var contador_circulos = 0
		var contador_cruces = 0
		for c in range(grid_size):
			if grid_state[r][c] == CIRCULO:
				contador_circulos += 1
				contador_cruces = 0
			elif grid_state[r][c] == CRUZ:
				contador_cruces += 1
				contador_circulos = 0
			else:
				contador_circulos = 0
				contador_cruces = 0
				
			if contador_circulos >= 4:
				return [false, "¡Cuidado! Revisa la fila %s. Veo cuatro o más círculos seguidos." % (r + 1)]
			if contador_cruces >= 4:
				return [false, "¡Cuidado! Revisa la fila %s. Veo cuatro o más cruces seguidas." % (r + 1)]

	# Comprobar Columnas
	for c in range(grid_size):
		var contador_circulos = 0
		var contador_cruces = 0
		for r in range(grid_size):
			if grid_state[r][c] == CIRCULO:
				contador_circulos += 1
				contador_cruces = 0
			elif grid_state[r][c] == CRUZ:
				contador_cruces += 1
				contador_circulos = 0
			else:
				contador_circulos = 0
				contador_cruces = 0
				
			if contador_circulos >= 4:
				return [false, "¡Cuidado! Revisa la columna %s. Tienes cuatro o más círculos seguidos." % (c + 1)]
			if contador_cruces >= 4:
				return [false, "¡Cuidado! Revisa la columna %s. Tienes cuatro o más cruces seguidas." % (c + 1)]

	# Comprobar Diagonales
	for i in range(-grid_size + 1, grid_size):
		var contador_circulos_1 = 0
		var contador_cruces_1 = 0
		var contador_circulos_2 = 0
		var contador_cruces_2 = 0
		
		for j in range(grid_size):
			var r1 = j
			var c1 = i + j
			var r2 = j
			var c2 = grid_size - 1 - (i + j)

			if c1 >= 0 and c1 < grid_size:
				if grid_state[r1][c1] == CIRCULO:
					contador_circulos_1 += 1
					contador_cruces_1 = 0
				elif grid_state[r1][c1] == CRUZ:
					contador_circulos_1 += 1
					contador_circulos_1 = 0
				else:
					contador_circulos_1 = 0
					contador_circulos_1 = 0
					
				if contador_circulos_1 >= 4:
					return [false, "¡Uy! He encontrado cuatro o más círculos seguidos en una diagonal."]
				if contador_cruces_1 >= 4:
					return [false, "¡Uy! He encontrado cuatro o más cruces seguidas en una diagonal."]

			if c2 >= 0 and c2 < grid_size:
				if grid_state[r2][c2] == CIRCULO:
					contador_circulos_2 += 1
					contador_cruces_2 = 0
				elif grid_state[r2][c2] == CRUZ:
					contador_circulos_2 += 1
					contador_circulos_2 = 0
				else:
					contador_circulos_2 = 0
					contador_circulos_2 = 0

				if contador_circulos_2 >= 4:
					return [false, "¡Uy! He encontrado cuatro o más círculos seguidos en una diagonal."]
				if contador_cruces_2 >= 4:
					return [false, "¡Uy! He encontrado cuatro o más cruces seguidas en una diagonal."]

	# ----- VICTORIA -----
	return [true, "¡VICTORIA!"]
