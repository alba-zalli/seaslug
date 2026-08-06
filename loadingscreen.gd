extends Control

@export var loading_duration: float = 1.5

@onready var progress_bar: ProgressBar = (
	get_node_or_null("ProgressBar") as ProgressBar
)

@onready var loading_label: Label = (
	get_node_or_null("Label") as Label
)

var destination_scene: String = ""
var elapsed_time: float = 0.0
var transition_started: bool = false


func _ready() -> void:
	destination_scene = SceneLoader.destination_scene

	print("Loading screen received: ", destination_scene)

	if progress_bar == null:
		_fail("ProgressBar node was not found.")
		return

	if loading_label == null:
		_fail("Label node was not found.")
		return

	if destination_scene.is_empty():
		_fail("No world scene was selected.")
		return

	if not ResourceLoader.exists(destination_scene):
		_fail(
			"World scene does not exist: "
			+ destination_scene
		)
		return

	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0

	loading_label.text = "Loading world... 0%"

	set_process(true)


func _process(delta: float) -> void:
	if transition_started:
		return

	elapsed_time += delta

	var percentage: float = clampf(
		(elapsed_time / loading_duration) * 100.0,
		0.0,
		100.0
	)

	progress_bar.value = percentage

	loading_label.text = (
		"Loading world... "
		+ str(roundi(percentage))
		+ "%"
	)

	if elapsed_time >= loading_duration:
		_open_destination_scene()


func _open_destination_scene() -> void:
	if transition_started:
		return

	transition_started = true
	set_process(false)

	progress_bar.value = 100.0
	loading_label.text = "Opening world..."

	print("Opening destination: ", destination_scene)

	var scene_path: String = destination_scene

	# Reset before leaving the loading scene.
	SceneLoader.reset()

	var error: Error = get_tree().change_scene_to_file(
		scene_path
	)

	if error != OK:
		transition_started = false
		_fail(
			"Could not open world. Error: "
			+ str(error)
		)


func _fail(message: String) -> void:
	set_process(false)

	if loading_label != null:
		loading_label.text = message

	SceneLoader.reset()
	push_error(message)
