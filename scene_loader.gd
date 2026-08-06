extends Node

const LOADING_SCREEN: PackedScene = preload(
	"res://bgscenes/loading.tscn"
)


func load_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("Scene path is empty.")
		return

	var loading_screen: Node = LOADING_SCREEN.instantiate()

	loading_screen.destination_scene = scene_path

	get_tree().root.add_child(loading_screen)

	var current_scene: Node = get_tree().current_scene

	if current_scene != null:
		current_scene.queue_free()

	get_tree().current_scene = loading_screen
