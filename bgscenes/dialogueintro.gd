extends Node

@onready var happy_alba: Sprite2D = $happy_alba

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(preload("res://dialogue/gameintroduction.dialogue"), "start", [self])

func change_to_sandbox() -> void:
	get_tree().change_scene_to_file("res://bgscenes/sandboxscreen.tscn")

func change_to_world() -> void:
	get_tree().change_scene_to_file("res://bgscenes/worldmode.tscn")

func change_to_happy(sprite_name: String) -> void:
	match sprite_name:
		"happy_alba":
			happy_alba.show()

func hide_sprite(sprite_name: String) -> void:
	match sprite_name:
		"happy_alba":
			happy_alba.hide()
