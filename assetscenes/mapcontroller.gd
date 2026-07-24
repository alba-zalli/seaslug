extends Node

@export var world_dialogue: DialogueResource = preload("res://dialogue/worldmode.dialogue")
var balloon_open := false

func _ready():
	print("CONTROLLER SCRIPT IS RUNNING")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	var regions = get_tree().get_nodes_in_group("map_regions")
	print("Found regions: ", regions.size())
	for region in regions:
		region.region_hovered.connect(_on_region_hovered)
	balloon_open = true
	DialogueManager.show_dialogue_balloon(world_dialogue, "intro", [self])

func _on_region_hovered(dialogue_title: String) -> void:
	balloon_open = false
	print("Hovered region: ", dialogue_title)
	if balloon_open:
		return
	balloon_open = true
	DialogueManager.show_dialogue_balloon(world_dialogue, dialogue_title, [self])

func _on_dialogue_ended(_resource) -> void:
	balloon_open = false
