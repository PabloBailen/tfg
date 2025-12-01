# HubMundos.gd
extends Control

# Cargamos la plantilla de la tarjeta
var tarjeta_scene = preload("res://TarjetaMundo.tscn")

# Datos de tus mundos
var datos_mundos = [
	{
		"titulo": "Bosque de la Lógica",
		"desc": "Adéndrate en el misterioso bosque de la lógica y aprende más sobre nuestro amigo capibara resolviendo acertijos gracias a tu intelecto 🧠",
		"img": preload("res://mundo_logica.png"), # Asegúrate que esta imagen existe
		# IMPORTANTE: Esta ruta debe ser EXACTA al nombre de tu archivo
		"escena": "res://MenuNivelesLogica.tscn" 
	},
	{
		"titulo": "Montaña del Código",
		"desc": "Próximamente...",
		"img": preload("res://patronhierba.png"),
		"escena": "" # Vacío porque aún no existe
	},
	# Puedes copiar y pegar el bloque de arriba para tener 4 tarjetas y ver cómo queda el Grid
	{
		"titulo": "Mundo 3",
		"desc": "Próximamente...",
		"img": preload("res://patronhierba.png"),
		"escena": ""
	},
	{
		"titulo": "Examen Final",
		"desc": "Demuestra lo que sabes.",
		"img": preload("res://patronhierba.png"),
		"escena": ""
	}
]

@onready var grid_mundos = $CenterContainer/GridMundos
@onready var boton_volver = $BotonVolver # Asegúrate de que tu botón se llame así en la escena

func _ready():
	# 1. Conectar el botón VOLVER (Esto faltaba antes)
	boton_volver.pressed.connect(_on_boton_volver_pressed)

	# 2. Limpiar tarjetas de prueba
	for hijo in grid_mundos.get_children():
		hijo.queue_free()
		
	# 3. Crear las tarjetas
	for datos in datos_mundos:
		var tarjeta = tarjeta_scene.instantiate()
		grid_mundos.add_child(tarjeta)
		
		tarjeta.configurar(datos["titulo"], datos["desc"], datos["img"], datos["escena"])
		
		# Conectar la señal de la tarjeta
		tarjeta.mundo_seleccionado.connect(_on_mundo_seleccionado)

func _on_boton_volver_pressed():
	# Vuelve al menú principal
	get_tree().root.get_node("Main").change_scene_to_file("res://MenuPrincipal.tscn")

func _on_mundo_seleccionado(ruta_escena):
	if ruta_escena != "":
		get_tree().root.get_node("Main").change_scene_to_file(ruta_escena)
	else:
		print("Este mundo aún no está disponible.")
