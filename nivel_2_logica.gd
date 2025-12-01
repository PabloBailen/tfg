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
var fila_scene = preload("res://FilaPregunta.tscn")

# --- Datos del PDF ---
var enigmas = [
	{ "id": 1, "texto": "Suma los dos primeros números primos y multiplícalo por 4.", "letra": "I" },
	{ "id": 2, "texto": "3 grupos de 7 juncos. ¿Cuántas plantas hay en total?", "letra": "N" },
	{ "id": 3, "texto": "Siguiente número en la secuencia: 14, 17, 23, 32...", "letra": "F" },
	{ "id": 4, "texto": "45 pasos. Avanzo 12, retrocedo 3. ¿Cuántos faltan?", "letra": "O" },
	{ "id": 5, "texto": "Si 7-4=3 y 9-6=3. Entonces 13 - ? = 3", "letra": "R" },
	{ "id": 6, "texto": "Aprende 4 trucos/año durante 8 años. Este año olvidó 2. ¿Total?", "letra": "M" },
	{ "id": 7, "texto": "Divide 100 entre 10 y luego multiplica por 3.", "letra": "A" },
	{ "id": 8, "texto": "64 nenúfares. La mitad tienen flor. El 25% de esos tiene libélula.", "letra": "T" },
	{ "id": 9, "texto": "7 grupos de luciérnagas x 6 destellos cada uno.", "letra": "I" },
	{ "id": 10, "texto": "A 200 le quitas 47 y luego le sumas 15.", "letra": "C" },
	{ "id": 11, "texto": "Completa la secuencia: 5-11, 6-14, 8-20... 10-?", "letra": "A" }
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
	get_tree().root.get_node("Main").change_scene_to_file("res://MenuNivelesLogica.tscn")
