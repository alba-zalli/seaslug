extends Control

@export_file("*.tscn")
var destination_scene: String = ""

@export var minimum_display_time: float = 0.5

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var loading_label: Label = %LoadingLabel

var elapsed_time: float = 0.0
var loading_started: bool = false


func _ready() -> void:
	if destination_scene.is_empty():
		push_error("No destination scene was assigned.")
		return

	var error: Error = ResourceLoader.load_threaded_request(
		destination_scene,
		"PackedScene"
	)

	if error != OK:
		push_error(
			"Could not start loading: " + destination_scene
		)
		return

	loading_started = true


func _process(delta: float) -> void:
	if not loading_started:
		return

	elapsed_time += delta

	var progress: Array = []

	var status: ResourceLoader.ThreadLoadStatus = (
		ResourceLoader.load_threaded_get_status(
			destination_scene,
			progress
		)
	)

	if not progress.is_empty():
		var progress_value: float = float(progress[0])
		progress_bar.value = progress_value * 100.0

		loading_label.text = (
			"Loading... "
			+ str(roundi(progress_value * 100.0))
			+ "%"
		)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass

		ResourceLoader.THREAD_LOAD_LOADED:
			if elapsed_time >= minimum_display_time:
				_open_loaded_scene()

		ResourceLoader.THREAD_LOAD_FAILED:
			loading_started = false
			loading_label.text = "Loading failed."

		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			loading_started = false
			loading_label.text = "Invalid scene path."


func _open_loaded_scene() -> void:
	loading_started = false

	var loaded_resource: Resource = (
		ResourceLoader.load_threaded_get(
			destination_scene
		)
	)

	var packed_scene: PackedScene = loaded_resource as PackedScene

	if packed_scene == null:
		loading_label.text = "Could not open scene."
		return

	get_tree().change_scene_to_packed(packed_scene)
