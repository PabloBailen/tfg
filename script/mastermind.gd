# mastermind.gd
extends Control

signal nivel_completado
signal puzle_cerrado 

# --- REFERENCIAS (Ajustadas a tu imagen image_ebb13a.png) ---

# El contenedor donde estarán las 10 filas
@onready var tablero_ui = $LayoutPrincipal/LayoutJuego/ZonaTablero/TableroJuego

# El contenedor donde el jugador pone los iconos actuales
@onready var contenedor_input = $LayoutPrincipal/LayoutJuego/ZonaTablero/FilaActual

# Botones de Acción
@onready var boton_comprobar = $LayoutPrincipal/Botones/BotonAceptar
@onready var boton_borrar = $LayoutPrincipal/Botones/BotonBorrar
# Asumo que este botón está fuera del layout principal, como hijo directo de Mastermind
@onready var boton_volver = $BarraSuperior/BotonVolver

# Panel de Estado (Derecha)
# Ajusta "Label" y "Label2" si los renombraste, aquí uso los nombres de tu foto
@onready var label_tiempo = $BarraSuperior/TimerWrapper/LabelTiempo
@onready var label_record = $LayoutPrincipal/LayoutJuego/PanelEstado/VBoxContainer/Label2
@onready var label_comentarios = $LayoutPrincipal/LayoutJuego/PanelEstado/VBoxContainer/MensajeWrapper/LabelMensaje
@onready var capi_anim = $LayoutPrincipal/LayoutJuego/PanelEstado/VBoxContainer/CapiAnim

# Timer (Asegúrate de crear un nodo Timer llamado TimerJuego hijo de Mastermind)
@onready var timer_juego = $TimerJuego 

# --- RECURSOS ---
var fila_scene = preload("res://escenas/FilaMastermind.tscn") # ¡Asegúrate de que la ruta es correcta!

# Texturas de los roedores (0=Capi, 1=Raton, etc.)
var texturas = [
	preload("res://assets/capi_juego.png"),
	preload("res://assets/raton.png"),
	preload("res://assets/hamster.png"),
	preload("res://assets/ardilla.png"),
	preload("res://assets/castor.png"),
	preload("res://assets/erizo.png")
]

# --- VARIABLES ---
var codigo_secreto = []
var intento_actual = [] 
var max_intentos = 10
var turno_actual = 0 
var segundos_transcurridos = 0
var juego_terminado = false
var fila_input_ui = [] # Lista para guardar los TextureRects de la fila de entrada

func _ready():
	randomize()
	
	# 1. Preparar la fila de entrada (buscar los TextureRects dentro de los Paneles)
	fila_input_ui.clear()
	for hijo in contenedor_input.get_children():
		# Buscamos si hay un TextureRect dentro
		var tex = hijo.get_node_or_null("TextureRect")
		if tex:
			fila_input_ui.append(tex)
		elif hijo is TextureRect:
			fila_input_ui.append(hijo)
	
	# 2. Inicializar juego
	_generar_codigo_secreto()
	_inicializar_tablero_vacio()
	
	# 3. Mostrar Récord
	# (Descomenta si ya tienes ProgresoJuego funcionando)
	# if ProgresoJuego:
	# 	var record = ProgresoJuego.record_mastermind
	# 	if record == 99: label_record.text = "Récord: --"
	# 	else: label_record.text = "Récord: %d" % record
	
	# 4. Conectar Botones de Roedores
	var contenedor_selectores = $LayoutPrincipal/Selectores
	for i in range(contenedor_selectores.get_child_count()):
		var btn = contenedor_selectores.get_child(i)
		if btn is BaseButton:
			if not btn.pressed.is_connected(_on_selector_pressed):
				btn.pressed.connect(_on_selector_pressed.bind(i))
	
	# 5. Conectar Acciones
	boton_comprobar.pressed.connect(_on_comprobar_pressed)
	boton_borrar.pressed.connect(_on_borrar_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)
	
	# 6. Timer
	if timer_juego:
		timer_juego.timeout.connect(_on_timer_timeout)
		timer_juego.start()
		
	# Mensaje inicial
	label_comentarios.text = "¡Adivina mi código secreto!"
	if capi_anim: capi_anim.play("idle")

# --- FUNCIONES DE INICIO ---
func _generar_codigo_secreto():
	codigo_secreto.clear()
	for i in range(5):
		codigo_secreto.append(randi() % 6)
	print("Secreto (Cheat): ", codigo_secreto) 

# mastermind.gd

func _inicializar_tablero_vacio():
	for hijo in tablero_ui.get_children():
		hijo.queue_free()
	
	# Colores para el gradiente
	var color_inicio = Color(0.2, 0.8, 0.2, 0.8) # Verde
	var color_fin = Color(0.9, 0.1, 0.1, 0.8)    # Rojo
	
	for i in range(max_intentos):
		var fila = fila_scene.instantiate()
		tablero_ui.add_child(fila)
		
		# Calculamos el color intermedio
		# i / 9.0 nos da un número de 0.0 a 1.0 según la fila
		var color_gradiente = color_inicio.lerp(color_fin, float(i) / (max_intentos - 1))
		
		# Pasamos el color a la fila
		fila.configurar(i + 1, [], [], color_gradiente)

# --- INTERACCIÓN ---
func _on_selector_pressed(id_roedor):
	print("--- CLICK DETECTADO ---")
	print("Has pulsado el roedor número: ", id_roedor)
	
	if juego_terminado: 
		print("El juego ya terminó, no hago nada.")
		return
		
	if intento_actual.size() < 5:
		intento_actual.append(id_roedor)
		print("Añadido. Lista actual: ", intento_actual)
		_actualizar_fila_input_visual()
	else:
		print("La fila ya está llena (5 roedores).")

func _on_borrar_pressed():
	if juego_terminado: return
	if intento_actual.size() > 0:
		intento_actual.pop_back()
		_actualizar_fila_input_visual()

func _actualizar_fila_input_visual():
	print("Actualizando dibujos...")
	# Limpiar
	for rect in fila_input_ui:
		rect.texture = null
	
	# Poner iconos
	for i in range(intento_actual.size()):
		var id = intento_actual[i]
		if i < fila_input_ui.size():
			print("Poniendo textura ", id, " en el hueco ", i)
			fila_input_ui[i].texture = texturas[id]

# --- LÓGICA DE JUEGO ---
func _on_comprobar_pressed():
	if intento_actual.size() != 5:
		label_comentarios.text = "¡Necesito 5 roedores!"
		return
		
	# 1. Calcular Resultados
	var resultados = [0, 0, 0, 0, 0] # 0=Rojo, 1=Amarillo, 2=Verde
	var copia_secreto = codigo_secreto.duplicate()
	var copia_intento = intento_actual.duplicate()
	
	# Verdes
	for i in range(5):
		if copia_intento[i] == copia_secreto[i]:
			resultados[i] = 2
			copia_secreto[i] = -1
			copia_intento[i] = -2
			
	# Amarillos
	for i in range(5):
		if copia_intento[i] != -2:
			var indice = copia_secreto.find(copia_intento[i])
			if indice != -1:
				resultados[i] = 1
				copia_secreto[indice] = -1
	
	# 2. Actualizar la Fila en el Tablero
	var fila_a_actualizar = tablero_ui.get_child(turno_actual)
	
	var texturas_intento = []
	for id in intento_actual:
		texturas_intento.append(texturas[id])
		
	fila_a_actualizar.configurar(turno_actual + 1, texturas_intento, resultados)
	
	# 3. Comprobar Victoria/Derrota
	# (Aquí estaba el error antes, definimos 'ganado' aquí mismo)
	var ganado = true
	for res in resultados:
		if res != 2:
			ganado = false
			break
	
	if ganado:
		_juego_ganado()
	else:
		turno_actual += 1
		if turno_actual >= max_intentos:
			_juego_perdido()
		else:
			label_comentarios.text = "¡Casi! Sigue intentándolo."
			intento_actual.clear()
			_actualizar_fila_input_visual()

func _juego_ganado():
	juego_terminado = true
	timer_juego.stop()
	boton_comprobar.disabled = true
	label_comentarios.text = "¡VICTORIA! Eres un genio."
	if capi_anim: capi_anim.play("talking")
	
	# Guardar Récord (Opcional por ahora)
	# if ProgresoJuego and turno_actual + 1 < ProgresoJuego.record_mastermind:
	# 	ProgresoJuego.record_mastermind = turno_actual + 1
	# 	ProgresoJuego.guardar_partida()

func _juego_perdido():
	juego_terminado = true
	timer_juego.stop()
	boton_comprobar.disabled = true
	label_comentarios.text = "Oh no... Se acabaron los intentos."
	# Mostrar solución (opcional)

func _on_timer_timeout():
	segundos_transcurridos += 1
	var m = segundos_transcurridos / 60
	var s = segundos_transcurridos % 60
	label_tiempo.text = "%02d:%02d" % [m, s]

func _on_volver_pressed():
	# Usamos el Director (Main) para volver, si existe
	print("Boton pulsado")
	var main = get_tree().root.get_node("Main")
	if main:
		main.change_scene_to_file("res://escenas/MenuNivelesLogica.tscn")
	else:
		get_tree().change_scene_to_file("res://escenas/MenuNivelesLogica.tscn")
