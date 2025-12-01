# menu_niveles_logica.gd
extends Control

# Preca-rgamos las escenas necesarias
const PuzleNuncaCuatro = preload("res://Puzle_NuncaCuatro.tscn")
var tarjeta_scene = preload("res://TarjetaMundo.tscn")

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
		"titulo": "Nivel 1: Causa y Efecto",
		"desc": "Conceptos básicos.",
		"img": preload("res://patronhierba.png"),
		"accion": "PENDIENTE" 
	},
	{
		"titulo": "Nivel 2: La Afición de Capi",
		"desc": "Descubre la palabra oculta con matemáticas.",
		"img": preload("res://patronhierba.png"),
		"accion": "res://Nivel_2_Logica.tscn" 
	},
	{
		"titulo": "Nivel 3: Series",
		"desc": "El puzle de lógica Nunca 4.",
		"img": preload("res://patronhierba.png"),
		"accion": "ABRIR_SELECTOR_DIFICULTAD" 
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
	# Limpiamos cualquier cosa que hubiera antes
	for hijo in grid_niveles.get_children():
		hijo.queue_free()
		
	for datos in datos_niveles:
		var tarjeta = tarjeta_scene.instantiate()
		grid_niveles.add_child(tarjeta)
		
		# Configuramos la tarjeta con los datos
		# El último dato ('accion') se enviará cuando pulsemos el botón
		tarjeta.configurar(datos["titulo"], datos["desc"], datos["img"], datos["accion"])
		
		# Escuchamos la señal de la tarjeta
		tarjeta.mundo_seleccionado.connect(_on_tarjeta_pulsada)

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
	get_tree().root.get_node("Main").change_scene_to_file("res://HubMundos.tscn")
