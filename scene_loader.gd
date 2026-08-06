extends Node

const LOADING_SCREEN_PATH: String = (
	"res://bgscenes/loading.tscn"
)

var destination_scene: String = ""
var is_loading: bool = false


func load_scene(scene_path: String) -> void:
	if is_loading:
		print("A scene is already loading.")
		return

	if scene_path.is_empty():
		push_error("SceneLoader received an empty path.")
		return

	if not ResourceLoader.exists(scene_path):
		push_error(
			"Destination scene does not exist: "
			+ scene_path
		)
		return

	destination_scene = scene_path
	is_loading = true

	print("Selected destination: ", destination_scene)

	var error: Error = get_tree().change_scene_to_file(
		LOADING_SCREEN_PATH
	)

	if error != OK:
		push_error(
			"Could not open loading screen. Error: "
			+ str(error)
		)

		reset()


func reset() -> void:
	destination_scene = ""
	is_loading = false
