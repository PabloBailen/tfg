# ProgresoJuego.gd
extends Node

const RUTA_GUARDADO = "user://datos_juego.cfg"

# Diccionario para saber qué niveles están desbloqueados
# Por defecto, solo el Nivel 1 está desbloqueado (true)
var niveles_desbloqueados = {
	1: true,
	2: false,
	3: false,
	4: false
	# Añade más según necesites
}

func _ready():
	cargar_partida()

# Llamaremos a esto cuando ganes un nivel
func completar_nivel(numero_nivel_completado):
	print("Nivel %s completado. Guardando..." % numero_nivel_completado)
	
	# 1. Desbloqueamos el SIGUIENTE nivel
	var siguiente_nivel = numero_nivel_completado + 1
	
	# Solo si existe ese nivel en nuestro diccionario
	if siguiente_nivel in niveles_desbloqueados:
		niveles_desbloqueados[siguiente_nivel] = true
		guardar_partida() # Guardamos en disco inmediatamente

func guardar_partida():
	var archivo = ConfigFile.new()
	
	# Guardamos cada nivel en el archivo
	for nivel in niveles_desbloqueados:
		var estado = niveles_desbloqueados[nivel]
		# Sección "Niveles", Clave "1", Valor true/false
		archivo.set_value("Niveles", str(nivel), estado)
	
	# Escribimos el archivo en el disco
	archivo.save(RUTA_GUARDADO)

func cargar_partida():
	var archivo = ConfigFile.new()
	var error = archivo.load(RUTA_GUARDADO)
	
	# Si el archivo existe y se cargó bien
	if error == OK:
		for nivel in niveles_desbloqueados:
			# Leemos el valor del archivo. Si no existe, usamos el valor por defecto (false)
			var guardado = archivo.get_value("Niveles", str(nivel), false)
			# IMPORTANTE: Mantenemos true si ya estaba desbloqueado por defecto (como el nivel 1)
			if guardado == true:
				niveles_desbloqueados[nivel] = true
	else:
		print("No hay partida guardada, usando valores por defecto.")
