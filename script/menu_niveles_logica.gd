# menu_niveles_logica.gd
extends Control

# Preca-rgamos las escenas necesarias
const PuzleNuncaCuatro = preload("res://escenas/Puzle_NuncaCuatro.tscn")
var tarjeta_scene = preload("res://escenas/TarjetaMundo.tscn")

# Variable para controlar si ya hay un puzle abierto
var puzle_instancia = null

# --- Referencias a los nodos ---
@onready var grid_niveles = $ScrollContainer/CenterContainer/GridNiveles
@onready var contenedor_puzles = $ContenedorPuzles
@onready var panel_dificultad = $PanelDificultad # Tu popup
@onready var boton_volver = $BotonVolver

# --- Referencias a los botones DEL POPUP ---
# Ajusta estas rutas si tu estructura dentro del Panel es diferente
@onready var btn_facil = $PanelDificultad/VBoxContainer/BotonFacil
@onready var btn_medio = $PanelDificultad/VBoxContainer/BotonMedio
@onready var btn_dificil = $PanelDificultad/VBoxContainer/BotonDificil
@onready var btn_cancelar = $PanelDificultad/VBoxContainer/BotonCancelar

# --- Datos de los Niveles ---
var datos_niveles = [
	{
		"titulo": "Nunca 4",
		"desc": "El puzle de lógica Nunca 4.",
		"img": preload("res://assets/foto_nunca.png"),
		"accion": "ABRIR_SELECTOR_DIFICULTAD" 
	}, 
	{
		"titulo": "Mastermind",
		"desc": "Descubre el código secreto en el menor número de intentos posible",
		"img": preload("res://assets/foto_masterminf.png"),
		"accion": "res://escenas/Mastermind.tscn" 
	},
		{
		"titulo": "Puertas de la Lógica",
		"desc": "Conecta el circuito a través de las puertas para resolver el nivel",
		"img": preload("res://assets/foto_puertas.png"),
		"accion": "res://escenas/Nivel_2_Logica.tscn" 
	}
]

func _ready():
	# 1. Conectar el botón VOLVER general
	boton_volver.pressed.connect(_on_boton_volver_pressed)
	
	# 2. Conectar los botones del POPUP de Dificultad
	# Usamos .bind() para pasar el tamaño del grid (5, 8, 12)
	btn_facil.pressed.connect(_iniciar_juego_con_dificultad.bind(5))
	btn_medio.pressed.connect(_iniciar_juego_con_dificultad.bind(8))
	btn_dificil.pressed.connect(_iniciar_juego_con_dificultad.bind(12))
	btn_cancelar.pressed.connect(_cerrar_popup)

	# 3. Generar las tarjetas
	_generar_tarjetas()

func _generar_tarjetas():
	# Limpiar
	for hijo in grid_niveles.get_children():
		hijo.queue_free()
		
	# Recorremos los datos. Usamos un índice 'i' para saber si es el nivel 1, 2, 3...
	for i in range(datos_niveles.size()):
		var datos = datos_niveles[i]
		var numero_nivel = i + 1 # Porque el array empieza en 0 pero tus niveles en 1
		
		var tarjeta = tarjeta_scene.instantiate()
		grid_niveles.add_child(tarjeta)
		
		# --- LÓGICA DE BLOQUEO ---
		# Preguntamos al Global si este nivel está desbloqueado
		#var esta_desbloqueado = ProgresoJuego.niveles_desbloqueados.get(numero_nivel, false)
		#TEMPORAL
		var esta_desbloqueado = true
		if esta_desbloqueado:
			# Si está desbloqueado, configuramos normal
			tarjeta.configurar(datos["titulo"], datos["desc"], datos["img"], datos["accion"])
			tarjeta.mundo_seleccionado.connect(_on_tarjeta_pulsada)
		else:
			# Si está BLOQUEADO, mostramos un candado o lo oscurecemos
			tarjeta.configurar("Bloqueado", "Completa el nivel anterior", datos["img"], "")
			tarjeta.modulate = Color(0.5, 0.5, 0.5) # Oscurecer la tarjeta
			# No conectamos la señal, así que el botón no hace nada
			
func _on_tarjeta_pulsada(accion):
	if accion == "ABRIR_SELECTOR_DIFICULTAD":
		panel_dificultad.visible = true
		
	elif accion == "PENDIENTE":
		print("Este nivel aún no está implementado")
		
	else:
		# ¡AQUÍ ESTABA EL FALLO! Ahora sí cargamos la escena
		print("Cargando nivel: ", accion)
		get_tree().root.get_node("Main").change_scene_to_file(accion)
		pass

# Esta función se ejecuta al pulsar Fácil, Medio o Difícil en el Popup
func _iniciar_juego_con_dificultad(tamano):
	# 1. Ocultamos el popup
	panel_dificultad.visible = false
	
	# 2. Abrimos el puzle con el tamaño elegido
	_abrir_puzle_real(tamano)

func _cerrar_popup():
	panel_dificultad.visible = false

# Lógica para instanciar y mostrar el puzle
func _abrir_puzle_real(grid_size):
	if puzle_instancia != null: return

	puzle_instancia = PuzleNuncaCuatro.instantiate()
	puzle_instancia.grid_size = grid_size # Pasamos la dificultad
	
	puzle_instancia.nivel_completado.connect(_on_puzle_completado)
	puzle_instancia.puzle_cerrado.connect(_on_puzle_cerrado)

	contenedor_puzles.add_child(puzle_instancia)

func _on_puzle_completado():
	# Aquí guardarías el progreso
	_on_puzle_cerrado()

func _on_puzle_cerrado():
	if puzle_instancia != null:
		puzle_instancia.queue_free()
		puzle_instancia = null

func _on_boton_volver_pressed():
	# Volver al Hub de mundos
	get_tree().root.get_node("Main").change_scene_to_file("res://escenas/HubMundos.tscn")
