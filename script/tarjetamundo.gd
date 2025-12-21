# TarjetaMundo.gd
extends PanelContainer

# Señal para avisar al Hub que se ha pulsado este mundo
signal mundo_seleccionado(nombre_mundo)

@onready var titulo_lbl = $VBoxContainer/TituloMundo
@onready var foto_rect = $VBoxContainer/FotoMundo
@onready var desc_lbl = $VBoxContainer/Descripcion
@onready var boton = $VBoxContainer/BotonEntrar

# Variable para guardar la ruta de la escena a cargar
var escena_destino = ""

func _ready():
	boton.pressed.connect(_on_boton_entrar_pressed)

# Función para configurar la tarjeta desde fuera
func configurar(titulo, descripcion, textura, ruta_escena):
	titulo_lbl.text = titulo
	desc_lbl.text = descripcion
	foto_rect.texture = textura
	escena_destino = ruta_escena

func _on_boton_entrar_pressed():
	# Emitimos la señal con la ruta
	mundo_seleccionado.emit(escena_destino)
