# MundoLogica_TEST.gd
extends Node2D

const PuzleNuncaCuatro = preload("res://Puzle_NuncaCuatro.tscn")
var puzle_instancia = null

func _ready():
	# Conecta los 3 botones de dificultad
	$VBoxContainer/BotonFacil.pressed.connect(_on_dificultad_presionada.bind(5))
	$VBoxContainer/BotonMedio.pressed.connect(_on_dificultad_presionada.bind(8))
	$VBoxContainer/BotonDificil.pressed.connect(_on_dificultad_presionada.bind(12))

# Esta función se llama cuando se pulsa CUALQUIER botón de dificultad
func _on_dificultad_presionada(tamano_grid):
	print("Botón presionado, abriendo puzle de %sx%s..." % [tamano_grid, tamano_grid])
	
	# Si ya hay un puzle, no hagas nada (o ciérralo primero)
	if puzle_instancia != null:
		return

	# 1. Crea una copia (instancia) del puzle
	puzle_instancia = PuzleNuncaCuatro.instantiate()
	
	# 2. ¡IMPORTANTE! Le "decimos" al puzle qué tamaño debe tener
	puzle_instancia.grid_size = tamano_grid

	# 3. Conecta las "señales" del puzle
	puzle_instancia.nivel_completado.connect(_on_puzle_completado)
	puzle_instancia.puzle_cerrado.connect(_on_puzle_cerrado)

	# 4. Añade el puzle a la pantalla
	$ContenedorPuzles.add_child(puzle_instancia)

# Esta función se llama sola cuando el puzle "grita" nivel_completado
func _on_puzle_completado():
	print("¡SEÑAL DE VICTORIA RECIBIDA!")
	_on_puzle_cerrado() # Cierra el puzle al ganar

# Esta función se llama sola cuando el puzle "grita" puzle_cerrado
func _on_puzle_cerrado():
	print("¡SEÑAL DE CERRAR RECIBIDA!")
	if puzle_instancia != null:
		puzle_instancia.queue_free()
		puzle_instancia = null
		print("Puzle cerrado.")
