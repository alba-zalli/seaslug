extends Node2D

@export var tutorial_dialogue: DialogueResource = preload(
	"res://dialogue/tutorial.dialogue"
)

@export var tutorial_title: String = "start"

@export var start_tutorial_automatically: bool = false


@onready var happy_alba: Sprite2D = get_node_or_null("happy_alba")
@onready var shocked_alba: Sprite2D = get_node_or_null("shocked_alba")
@onready var confused_alba: Sprite2D = get_node_or_null("confused_alba")


var tutorial_is_open: bool = false


func _ready() -> void:
	hide_sprite()

	var tutorial_button := _find_tutorial_button()

	if tutorial_button != null:
		if not tutorial_button.pressed.is_connected(
			_on_tutorial_button_pressed
		):
			tutorial_button.pressed.connect(
				_on_tutorial_button_pressed
			)
	else:
		push_warning(
			"Tutorial button was not found in scene: %s"
			% scene_file_path
		)

	if not DialogueManager.dialogue_ended.is_connected(
		_on_dialogue_ended
	):
		DialogueManager.dialogue_ended.connect(
			_on_dialogue_ended
		)

	if start_tutorial_automatically:
		call_deferred("start_tutorial")


func _find_tutorial_button() -> Button:
	# Structure used by the standalone sandbox scene.
	var button := get_node_or_null(
		"Top Menu/Tutorial"
	) as Button

	if button != null:
		return button

	# Structure used by West Pacific, East Pacific,
	# and Indian Ocean scenes.
	button = get_node_or_null(
		"SandboxScreen/Top Menu/Tutorial"
	) as Button

	if button != null:
		return button

	# Final fallback: search recursively by node name.
	return find_child(
		"Tutorial",
		true,
		false
	) as Button


func _on_tutorial_button_pressed() -> void:
	start_tutorial()


func start_tutorial() -> void:
	if tutorial_is_open:
		return

	if not is_instance_valid(tutorial_dialogue):
		push_error("The tutorial dialogue resource is missing.")
		return

	tutorial_is_open = true

	DialogueManager.show_dialogue_balloon(
		tutorial_dialogue,
		tutorial_title,
		[self]
	)


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource != tutorial_dialogue:
		return

	tutorial_is_open = false
	hide_sprite()


func change(sprite_name: String) -> void:
	hide_sprite()

	match sprite_name:
		"happy_alba":
			if happy_alba != null:
				happy_alba.show()

		"shocked_alba":
			if shocked_alba != null:
				shocked_alba.show()

		"confused_alba":
			if confused_alba != null:
				confused_alba.show()

		_:
			push_warning(
				"Unknown Alba sprite: %s" % sprite_name
			)


func hide_sprite() -> void:
	if happy_alba != null:
		happy_alba.hide()

	if shocked_alba != null:
		shocked_alba.hide()

	if confused_alba != null:
		confused_alba.hide()


func _on_mute_button_down() -> void:
	pass # Replace with function body.
