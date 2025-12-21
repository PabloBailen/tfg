# FilaPregunta.gd
extends PanelContainer

@onready var label_info = $HBoxContainer/LabelInfo
@onready var label_pregunta = $HBoxContainer/LabelPregunta
@onready var input_borrador = $HBoxContainer/InputBorrador

func configurar(id, letra, texto_pregunta):
	label_info.text = "Pista: Letra %s" % [letra] 
	label_pregunta.text = texto_pregunta
