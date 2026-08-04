extends Node

@export var world_dialogue: DialogueResource = preload("res://dialogue/worldmode.dialogue")
@export var visit_button: Button
var balloon_open := false

# Remembers whichever region was hovered most recently (stays set even
# after the mouse leaves), so the button knows what to open whether the
# region is currently hovered or was only hovered previously.
var last_hovered_region: String = ""

# TODO: update these paths once the West/East Pacific scenes exist —
# right now only IndianOceanScene.tscn is in the repo.
const REGION_SCENES := {
	"indian_ocean": "res://IndianOceanScene.tscn",
	"west_pacific": "res://bgscenes/WestPacificScene.tscn",
	"east_pacific": "res://bgscenes/EastPacificScene.tscn",
}

func _ready():
	print("CONTROLLER SCRIPT IS RUNNING")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	var regions = get_tree().get_nodes_in_group("map_regions")
	print("Found regions: ", regions.size())
	for region in regions:
		region.region_hovered.connect(_on_region_hovered)
	if visit_button:
		visit_button.disabled = true
	balloon_open = true
	DialogueManager.show_dialogue_balloon(world_dialogue, "intro", [self])

func _on_region_hovered(dialogue_title: String) -> void:
	last_hovered_region = dialogue_title
	print("Hovered region: ", dialogue_title)
	if visit_button:
		visit_button.disabled = false
	if balloon_open:
		return
	balloon_open = true
	DialogueManager.show_dialogue_balloon(world_dialogue, dialogue_title, [self])

func _on_dialogue_ended(_resource) -> void:
	balloon_open = false

func _on_button_pressed() -> void:
	print("========== BUTTON CLICKED ==========")
	print("last_hovered_region = ", last_hovered_region)

	if last_hovered_region == "":
		print("NO REGION")
		return

	if not REGION_SCENES.has(last_hovered_region):
		print("REGION NOT FOUND IN DICTIONARY: ", last_hovered_region)
		return

	print("GOING TO: ", REGION_SCENES[last_hovered_region])

	var err := get_tree().change_scene_to_file(REGION_SCENES[last_hovered_region])

	print("CHANGE SCENE RESULT: ", err)
