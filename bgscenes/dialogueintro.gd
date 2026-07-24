extends Node

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(preload("res://dialogue/gameintroduction.dialogue"), "start", [self])

func change_to_sandbox() -> void:
	get_tree().change_scene_to_file("res://bgscenes/sandboxscreen.tscn")

func change_to_world() -> void:
	get_tree().change_scene_to_file("res://bgscenes/worldmode.tscn")
