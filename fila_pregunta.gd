# FilaPregunta.gd
extends PanelContainer

@onready var label_info = $HBoxContainer/LabelInfo
@onready var label_pregunta = $HBoxContainer/LabelPregunta
@onready var input_borrador = $HBoxContainer/InputBorrador

func configurar(id, letra, texto_pregunta):
	label_info.text = "%s. (Letra %s)" % [id, letra]
	label_pregunta.text = texto_pregunta
