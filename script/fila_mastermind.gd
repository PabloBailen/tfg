# fila_mastermind.gd
extends HBoxContainer

# Referencias
@onready var label_numero = $NumeroIntento # Asegúrate de tener este nodo en la escena
@onready var huecos = [$Hueco1, $Hueco2, $Hueco3, $Hueco4, $Hueco5]

const COLOR_VERDE = Color(0.4, 0.8, 0.4)
const COLOR_AMARILLO = Color(1.0, 0.866, 0.27)
const COLOR_ROJO = Color(0.8, 0.2, 0.2)
const COLOR_VACIO = Color(0.2, 0.2, 0.2, 0.5) # Gris oscuro transparente

func configurar(numero, iconos, resultados, color_numero = Color.WHITE):
	# 1. Poner el número de fila
	if label_numero:
		label_numero.text = str(numero)
		
		# Acceder al estilo del fondo del número para pintarlo
		# (Asegúrate de haberle puesto un StyleBoxFlat en el paso 1)
		var estilo_numero = label_numero.get_theme_stylebox("normal")
		if estilo_numero:
			var estilo_nuevo = estilo_numero.duplicate()
			estilo_nuevo.bg_color = color_numero # Pintamos el fondo del número
			label_numero.add_theme_stylebox_override("normal", estilo_nuevo)

	# 2. GESTIÓN DE FILA VACÍA VS RELLENA
	if iconos.is_empty():
		# CASO 1: LA FILA ESTÁ VACÍA (Solo mostramos los huecos oscuros)
		for i in range(5):
			var panel = huecos[i]
			var texture_rect = panel.get_node("TextureRect")
			
			# Quitamos la imagen (para que se vea el hueco vacío)
			texture_rect.texture = null
			
			# ¡IMPORTANTE! 
			# Aquí NO cambiamos el color. Dejamos el StyleBoxFlat oscuro 
			# que pusiste en el editor (Paso 2).
			
			# Si habías sobreescrito el estilo antes, lo limpiamos para volver al original:
			panel.remove_theme_stylebox_override("panel")
			
	else:
		# CASO 2: LA FILA TIENE DATOS (Pintamos colores y ponemos roedores)
		for i in range(5):
			var panel = huecos[i]
			var texture_rect = panel.get_node("TextureRect")
			
			# Poner la cara del roedor
			texture_rect.texture = iconos[i]
			
			# Colorear el fondo (Verde/Amarillo/Rojo)
			var nuevo_estilo = panel.get_theme_stylebox("panel").duplicate()
			
			match resultados[i]:
				2: nuevo_estilo.bg_color = COLOR_VERDE    # Acierto
				1: nuevo_estilo.bg_color = COLOR_AMARILLO # Casi
				0: nuevo_estilo.bg_color = COLOR_ROJO     # Fallo
			
			# Aplicamos el color encima del hueco
			panel.add_theme_stylebox_override("panel", nuevo_estilo)
