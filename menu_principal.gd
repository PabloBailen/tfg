# menu_principal.gd
extends Control

# Rutas a los botones
@onready var boton_jugar = $MenuLayout/ButtonLayout/BotonJugar
@onready var boton_opciones = $MenuLayout/ButtonLayout/BotonOpciones
@onready var boton_creditos = $MenuLayout/ButtonLayout/BotonCreditos
@onready var boton_salir = $MenuLayout/ButtonLayout/BotonSalir

func _ready():
	# Conectamos las señales
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)
	# (Conecta los otros si quieres)

func _on_boton_jugar_pressed():
	# Llama al Director (Main) para cambiar al juego
	get_tree().root.get_node("Main").change_scene_to_file("res://HubMundos.tscn")

func _on_boton_salir_pressed():
	get_tree().quit()
