# nivel_2_logica.gd
extends Control

# Señal para avisar al Main (si fuera necesario)
signal nivel_completado

# --- Referencias ---
@onready var contenedor_preguntas = $VBoxContainer/MarginContainer/ScrollContainer/GridCuestionario
@onready var input_final = $VBoxContainer/PanelSolucion/HBoxContainer/InputPalabraFinal
@onready var boton_comprobar = $VBoxContainer/PanelSolucion/HBoxContainer/BotonComprobar
@onready var boton_volver = $BotonVolver 
@onready var capi_anim = $CapiWrapper/CapiAnim

# Cargamos la plantilla visual que acabamos de crear
var fila_scene = preload("res://escenas/FilaPregunta.tscn")

# --- Datos del PDF ---
var enigmas = [
	{ "id": 1, "texto": "Completa la secuencia 1, 1, 2, 3, 5... ¿Cuál es el siguiente número?", "letra": "I" },
	{ "id": 2, "texto": "Si 7-4=3 y 9-6=3. Entonces 13 - ? = 3", "letra": "N" },
	{ "id": 3, "texto": "Cada vez que Capibyte encuentra un montón secreto hojas, añade siempre unas pocas más que en el anterior. Al primer montón añade 5 hojas, al segundo montón añade 10, al tercero 15. Si ahora descubre un cuarto montón, ¿Cuántas hojas añadirá esta vez?", "letra": "F" },
	{ "id": 4, "texto": "Continúa la serie 1, 3, 6, 10, 15 y ...", "letra": "O" },
	{ "id": 5, "texto": "Completa la secuencia: 5-11, 6-14, 8-20... 10-?", "letra": "R" },
	{ "id": 6, "texto": "En una vieja cabaña del bosque, Capibyte encontró una caja con 100 bellotas. Al abrirla descubrió que estaban organizadas en 10 montones iguales. Después decidió juntar los montones de 3 en 3. ¿Cuántas bellotas hay en cada nuevo montón?", "letra": "M" },
	{ "id": 7, "texto": "Capibyte ha ido reuniendo bayas mágicas durante años. Junta siempre 4 bayas nuevas cada año, pero este año algunas se le cayeron al río y perdió una. Si han pasado 8 años desde que empezó su colección, ¿cuántas bayas tiene ahora?", "letra": "A" },
	{ "id": 8, "texto": "Si A vale 1, B vale 2, C vale 3, D vale 4, etc. ¿Qué valor tiene la suma de las letras de la palabra NUBE?", "letra": "T" },
	{ "id": 9, "texto": "Encuentra el número siguiente: 14, 17, 23, 32...", "letra": "I" },
	{ "id": 10, "texto": "Capibyte quiere cruzar el bosque saltando solo por piedras marcadas con números. Cada piedra tiene el doble del número de la anterior más 6. Si la primera piedra tiene el número 12 y la segunda 30… ¿qué número tiene la tercera piedra?", "letra": "C" },
	{ "id": 11, "texto": "Si 9 es igual a 0, 8 es igual a 1, 7 es igual a 2... ¿Cuál es el valor de 8-3-1?", "letra": "A" }
]

func _ready():
	boton_comprobar.pressed.connect(_on_boton_comprobar_pressed)
	if boton_volver:
		boton_volver.pressed.connect(_on_boton_volver_pressed)
	
	if capi_anim:
		capi_anim.play("idle")
	
	generar_cuestionario()

func generar_cuestionario():
	# Limpiar
	for hijo in contenedor_preguntas.get_children():
		hijo.queue_free()
	
	# Barajar
	var lista_desordenada = enigmas.duplicate()
	lista_desordenada.shuffle()
	
	# Crear filas
	for datos in lista_desordenada:
		var nueva_fila = fila_scene.instantiate()
		
		# Añadimos al Grid (se ordenarán en 2 columnas automáticamente)
		contenedor_preguntas.add_child(nueva_fila)
		
		# Importante: Hacer que la fila se estire para llenar su celda
		nueva_fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		nueva_fila.configurar(datos["id"], datos["letra"], datos["texto"])
		
		# Nota: Ya no necesitamos el separador manual, el GridContainer lo hace solo

func _on_boton_comprobar_pressed():
	var texto_usuario = input_final.text.to_upper().strip_edges()
	
	if texto_usuario == "INFORMATICA" or texto_usuario == "INFORMÁTICA":
		print("¡VICTORIA!")
		input_final.modulate = Color.GREEN
		input_final.editable = false
		
		if capi_anim:
			capi_anim.play("talking")
		
		await get_tree().create_timer(2.0).timeout
		_on_boton_volver_pressed()
		
	else:
		print("Incorrecto")
		input_final.modulate = Color.RED
		input_final.text = ""
		await get_tree().create_timer(0.5).timeout
		input_final.modulate = Color.WHITE

func _on_boton_volver_pressed():
	get_tree().root.get_node("Main").change_scene_to_file("res://escenas/MenuNivelesLogica.tscn")
