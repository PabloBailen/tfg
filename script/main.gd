# main.gd
extends Node

# Escena que carga al inicio
@export var start_scene: PackedScene = preload("res://escenas/MenuPrincipal.tscn")

var current_scene = null

func _ready():
	if start_scene != null:
		change_scene(start_scene)

func change_scene(new_scene: PackedScene):
	if current_scene != null:
		current_scene.queue_free()
	
	current_scene = new_scene.instantiate()
	$SceneContainer.add_child(current_scene)

func change_scene_to_file(scene_path: String):
	var new_scene = load(scene_path)
	if new_scene != null:
		change_scene(new_scene)
