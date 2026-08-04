class_name DialogueManagerExampleBalloon
extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.


## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given title when using balloon as a Node in a scene.
@export var start_from_title: String = ""

## If running as a Node in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
## Keep this false so the background remains interactive.
@export var will_block_other_input: bool = false

## The action to use for advancing the dialogue.
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue.
@export var skip_action: StringName = &"ui_cancel"


## Sound player for voice lines.
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## The base balloon anchor.
@onready var balloon: Control = %Balloon

## The visible dialogue panel.
@onready var dialogue_panel: Control = \
	$Balloon/MarginContainer/PanelContainer

## The character-name label.
@onready var character_label: RichTextLabel = %CharacterLabel

## The dialogue text label.
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The response-options menu.
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator showing that dialogue can progress.
@onready var progress: Polygon2D = %Progress


## Temporary game states.
var temporary_game_states: Array = []

## Whether the current line is waiting for player input.
var is_waiting_for_input: bool = false

## Whether the balloon should hide during a long mutation.
var will_hide_balloon: bool = false

## Ephemeral dialogue variables.
var locals: Dictionary = {}

## Current language.
var _locale: String = TranslationServer.get_locale()

## Prevent the same click from advancing multiple lines.
var _advance_is_queued: bool = false


## The current dialogue line.
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# Dialogue has finished.
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line


## Cooldown timer used when hiding the balloon during mutations.
var mutation_cooldown: Timer = Timer.new()


func _ready() -> void:
	balloon.hide()

	Engine.get_singleton("DialogueManager").mutated.connect(
		_on_mutated
	)

	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(
		_on_mutation_cooldown_timeout
	)
	add_child(mutation_cooldown)

	_configure_mouse_filters()

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(
				false,
				DMConstants.get_error_message(
					DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART
				)
			)
			return

		start()


## Configure which dialogue controls intercept mouse clicks.
func _configure_mouse_filters() -> void:
	# The balloon and visible text panel must not block objects behind them.
	balloon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Ensure every nested visual element in the text panel is click-through.
	_set_text_controls_click_through(dialogue_panel)

	# Response buttons must remain interactive.
	_set_response_controls_interactive(responses_menu)


## Make visual controls click-through, except for the response menu.
func _set_text_controls_click_through(node: Node) -> void:
	if node == responses_menu:
		return

	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child: Node in node.get_children():
		_set_text_controls_click_through(child)


## Make response buttons clickable.
func _set_response_controls_interactive(node: Node) -> void:
	if node is BaseButton:
		node.mouse_filter = Control.MOUSE_FILTER_STOP
	elif node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_PASS

	for child: Node in node.get_children():
		_set_response_controls_interactive(child)


func _process(_delta: float) -> void:
	if not is_instance_valid(dialogue_line):
		return

	progress.visible = (
		not dialogue_label.is_typing
		and dialogue_line.responses.size() == 0
		and not dialogue_line.has_tag("voice")
	)


## Detect clicks on the dialogue panel without consuming them.
##
## Because this uses _input() and does not call set_input_as_handled(),
## the same click can also reach a background object.
func _input(event: InputEvent) -> void:
	if not visible:
		return

	if not is_instance_valid(dialogue_line):
		return

	# Keyboard advancement.
	if event.is_action_pressed(next_action):
		if dialogue_line.responses.size() > 0:
			return

		if dialogue_label.is_typing:
			dialogue_label.skip_typing()
			return

		if is_waiting_for_input:
			_queue_next_line()

		return

	if event.is_action_pressed(skip_action):
		if dialogue_label.is_typing:
			dialogue_label.skip_typing()

		return

	# Mouse input only from this point onward.
	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton

	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not mouse_event.pressed:
		return

	# Do not use panel clicks to advance when response options are showing.
	# The response buttons handle those clicks themselves.
	if dialogue_line.responses.size() > 0:
		return

	# Only react when the visible dialogue panel was clicked.
	if not dialogue_panel.get_global_rect().has_point(
		mouse_event.position
	):
		return

	if dialogue_label.is_typing:
		dialogue_label.skip_typing()
		return

	if not is_waiting_for_input:
		return

	# Do not mark this input as handled.
	# This allows the click to continue to the background.
	_queue_next_line()


## Queue advancement so the current input event finishes propagating first.
func _queue_next_line() -> void:
	if _advance_is_queued:
		return

	if not is_instance_valid(dialogue_line):
		return

	_advance_is_queued = true
	call_deferred(
		"_advance_to_next_line",
		dialogue_line.next_id
	)


func _advance_to_next_line(next_id: String) -> void:
	_advance_is_queued = false

	if not is_instance_valid(dialogue_line):
		return

	next(next_id)


func _unhandled_input(_event: InputEvent) -> void:
	# This should remain disabled when the background must be interactive.
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if (
		what == NOTIFICATION_TRANSLATION_CHANGED
		and _locale != TranslationServer.get_locale()
		and is_instance_valid(dialogue_label)
	):
		_locale = TranslationServer.get_locale()

		var visible_ratio: float = dialogue_label.visible_ratio

		dialogue_line = await dialogue_resource.get_next_dialogue_line(
			dialogue_line.id
		)

		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue.
func start(
	with_dialogue_resource: DialogueResource = null,
	title: String = "",
	extra_game_states: Array = []
) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	_advance_is_queued = false

	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource

	if not title.is_empty():
		start_from_title = title

	dialogue_line = await dialogue_resource.get_next_dialogue_line(
		start_from_title,
		temporary_game_states
	)

	show()


## Apply the current dialogue line to the balloon.
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	_advance_is_queued = false
	progress.hide()
	is_waiting_for_input = false

	# Do not focus the click-through balloon.
	balloon.focus_mode = Control.FOCUS_NONE

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(
		dialogue_line.character,
		"dialogue"
	)

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()

	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(
			dialogue_line.get_tag_value("voice")
		)
		audio_stream_player.play()

		await audio_stream_player.finished
		next(dialogue_line.next_id)

	elif dialogue_line.responses.size() > 0:
		# Response options should receive focus and mouse input.
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()

		# Response buttons may be created dynamically, so configure them
		# again after the responses are displayed.
		call_deferred(
			"_set_response_controls_interactive",
			responses_menu
		)

	elif dialogue_line.time != "":
		var time: float

		if dialogue_line.time == "auto":
			time = dialogue_line.text.length() * 0.02
		else:
			time = dialogue_line.time.to_float()

		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)

	else:
		is_waiting_for_input = true


## Go to the next dialogue line.
func next(next_id: String) -> void:
	is_waiting_for_input = false
	_advance_is_queued = false

	dialogue_line = await dialogue_resource.get_next_dialogue_line(
		next_id,
		temporary_game_states
	)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


## The text balloon no longer handles mouse clicks through gui_input.
##
## Mouse advancement is handled by _input(), allowing the event to continue
## to objects behind the dialogue panel.
func _on_balloon_gui_input(_event: InputEvent) -> void:
	pass


func _on_responses_menu_response_selected(
	response: DialogueResponse
) -> void:
	next(response.next_id)


#endregion
