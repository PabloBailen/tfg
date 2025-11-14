# Puzle_NuncaCuatro.gd
extends Control

signal nivel_completado
signal puzle_cerrado

# --- Rutas a Nodos ---
@onready var cuadricula_node = $LayoutPrincipal/CenterContainer/PuzzleLayout/Cuadricula
@onready var boton_comprobar_node = $LayoutPrincipal/PanelCapi/ButtonLayout/BotonComprobar
@onready var boton_salir_node = $LayoutPrincipal/PanelCapi/ButtonLayout/BotonSalir
@onready var panel_capi = $LayoutPrincipal/PanelCapi
@onready var label_mensaje = $LayoutPrincipal/PanelCapi/MensajeWrapper/LabelMensaje
@onready var capi_anim = $LayoutPrincipal/PanelCapi/CapiWrapper/CapiAnim
@onready var label_tiempo = $LayoutPrincipal/PanelCapi/TimerWrapper/LabelTiempo
@onready var timer_juego = $LayoutPrincipal/PanelCapi/TimerJuego

# --- Variables del Juego ---
var grid_state = []
@export var grid_size: int = 12 

@export var tex_vacia: Texture2D
@export var tex_circulo: Texture2D
@export var tex_cruz: Texture2D
@export var tex_bloqueada: Texture2D

var segundos_transcurridos = 0
var juego_terminado = false


const VACIO = 0
const CIRCULO = 1
const CRUZ = 2
const BLOQUEADO = 3

# --- Funciones del Juego ---

func _ready():
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
	
	# 4. "Perforamos" la solución para crear el PUZLE
	perforar_puzle()
	
	# (El bucle que cargaba puzzle_data ha sido eliminado)

	# 5. Crea los botones dinámicamente
	for r in range(grid_size):
		for c in range(grid_size):
			var boton = TextureButton.new()
			var tipo_casilla = grid_state[r][c]
			
			if tipo_casilla == VACIO:
				boton.pressed.connect(_on_casilla_pressed.bind(r, c))
				_actualizar_textura(boton, VACIO)
			else:
				boton.disabled = true
				_actualizar_textura(boton, tipo_casilla)
				boton.modulate = Color(0.7, 0.7, 0.7)
			
			cuadricula_node.add_child(boton)
			
	# Conecta los botones de Comprobar y Salir
	boton_comprobar_node.pressed.connect(_on_boton_comprobar_pressed)
	boton_salir_node.pressed.connect(_on_boton_salir_pressed)
	
	# Conecta el temporizador
	timer_juego.timeout.connect(_on_timer_juego_timeout)
	_actualizar_label_tiempo()
	
	# Asegura que Capi empiece en la animación de reposo
	capi_anim.play("idle")
	
	# Muestra el mensaje de bienvenida de Capi
	mostrar_mensaje.call_deferred("¡Rellena las casillas vacías! ¡Pero ojo, nunca 4 símbolos iguales seguidos!")

# ----------------------------------------------
# Funciones para el Temporizador
# ----------------------------------------------
func _on_timer_juego_timeout():
	if juego_terminado:
		return

	segundos_transcurridos += 1
	_actualizar_label_tiempo()

func _actualizar_label_tiempo():
	var minutos = segundos_transcurridos / 60
	var segundos = segundos_transcurridos % 60
	label_tiempo.text = "Tiempo: %02d:%02d" % [minutos, segundos]
# ----------------------------------------------

# ----------------------------------------------
# Función "Perforador" (PUZZLER)
# ----------------------------------------------
func perforar_puzle():
	var total_celdas = grid_size * grid_size
	var num_a_quitar = 0
	
	match grid_size:
		5:
			num_a_quitar = int(total_celdas * 0.40)
		8:
			num_a_quitar = int(total_celdas * 0.50)
		12:
			num_a_quitar = int(total_celdas * 0.50)
	
	var contador = 0
	while contador < num_a_quitar:
		var r = randi() % grid_size
		var c = randi() % grid_size
		if grid_state[r][c] != VACIO:
			grid_state[r][c] = VACIO
			contador += 1
			
# ----------------------------------------------
# FUNCIÓN SOLUCIONADOR (SOLVER)
# ----------------------------------------------
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
func _es_movimiento_valido(r, c):
	var tipo_actual = grid_state[r][c]
	if tipo_actual == VACIO:
		return true

	var contador = 0
	for i in range(grid_size):
		if grid_state[r][i] == tipo_actual:
			contador += 1
			if contador >= 4: return false
		else:
			contador = 0
	
	contador = 0
	for i in range(grid_size):
		if grid_state[i][c] == tipo_actual:
			contador += 1
			if contador >= 4: return false
		else:
			contador = 0
	
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

# --- (El resto de funciones) ---

func mostrar_mensaje(texto):
	label_mensaje.text = texto
	panel_capi.visible = true
	
	capi_anim.play("talking")
	
	var duracion_habla = max(1.5, texto.length() * 0.05)
	await get_tree().create_timer(duracion_habla).timeout
	
	capi_anim.play("idle")


func _on_casilla_pressed(r, c):
	if juego_terminado:
		return

	grid_state[r][c] = (grid_state[r][c] + 1) % 3
	var i = (r * grid_size) + c
	var boton = cuadricula_node.get_child(i)
	_actualizar_textura(boton, grid_state[r][c])


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

func _on_boton_comprobar_pressed():
	if juego_terminado:
		return

	print("Comprobando victoria...")
	
	var resultado = _comprobar_victoria()
	var es_valido = resultado[0]
	var mensaje_error = resultado[1]
	
	if es_valido == true:
		var mensaje_victoria = "¡Genial! ¡Lo has conseguido! Has entendido la lógica."
		print(mensaje_victoria)
		
		juego_terminado = true
		timer_juego.stop()
		boton_comprobar_node.disabled = true
		
		await mostrar_mensaje(mensaje_victoria)
		
	else:
		print("Aún no... Error: %s" % mensaje_error)
		await mostrar_mensaje(mensaje_error)


func _on_boton_salir_pressed():
	print("¡CLIC EN SALIR! - Emitiendo señal...")
	puzle_cerrado.emit()

func _comprobar_victoria():
	
	for r in range(grid_size):
		for c in range(grid_size):
			if grid_state[r][c] == VACIO:
				return [false, "¡Oh! Parece que aún te quedan casillas vacías por rellenar."]

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

	return [true, "¡VICTORIA!"]
