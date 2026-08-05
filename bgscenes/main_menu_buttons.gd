extends Button

@export_enum("wave", "shake", "tornado")
var hover_effect: String = "wave"

@export var wave_amplitude: float = 8.0
@export var wave_frequency: float = 3.0

@export var shake_rate: float = 18.0
@export var shake_level: float = 4.0

@export var tornado_radius: float = 3.0
@export var tornado_frequency: float = 3.0

var animated_label: RichTextLabel
var original_text: String


func _ready() -> void:
	original_text = text

	_create_animated_label()
	_hide_builtin_text()
	_show_normal_text()

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _create_animated_label() -> void:
	animated_label = RichTextLabel.new()
	animated_label.name = "AnimatedLabel"

	animated_label.bbcode_enabled = true
	animated_label.fit_content = false
	animated_label.scroll_active = false
	animated_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(animated_label)

	# Fill the complete button after it has a parent.
	animated_label.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	animated_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	animated_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_copy_button_theme()


func _copy_button_theme() -> void:
	var button_font := get_theme_font("font")
	var button_font_size := get_theme_font_size("font_size")

	animated_label.add_theme_font_override(
		"normal_font",
		button_font
	)

	animated_label.add_theme_font_size_override(
		"normal_font_size",
		button_font_size
	)

	animated_label.add_theme_color_override(
		"default_color",
		get_theme_color("font_color")
	)

	animated_label.add_theme_color_override(
		"font_outline_color",
		get_theme_color("font_outline_color")
	)

	animated_label.add_theme_constant_override(
		"outline_size",
		get_theme_constant("outline_size")
	)


func _hide_builtin_text() -> void:
	# Keep the original text so the Button retains its minimum size.
	# Only make the built-in text invisible.
	var transparent := Color(1.0, 1.0, 1.0, 0.0)

	add_theme_color_override("font_color", transparent)
	add_theme_color_override("font_hover_color", transparent)
	add_theme_color_override("font_pressed_color", transparent)
	add_theme_color_override("font_focus_color", transparent)
	add_theme_color_override("font_disabled_color", transparent)
	add_theme_color_override("font_hover_pressed_color", transparent)


func _on_mouse_entered() -> void:
	_show_animated_text()


func _on_mouse_exited() -> void:
	if not has_focus():
		_show_normal_text()


func _on_focus_entered() -> void:
	_show_animated_text()


func _on_focus_exited() -> void:
	if not is_hovered():
		_show_normal_text()


func _show_animated_text() -> void:
	if animated_label == null:
		return

	var safe_text := _escape_bbcode(original_text)

	match hover_effect:
		"shake":
			animated_label.text = (
				"[center][shake rate=%s level=%s connected=1]%s[/shake][/center]"
				% [
					shake_rate,
					shake_level,
					safe_text
				]
			)

		"tornado":
			animated_label.text = (
				"[center][tornado radius=%s freq=%s connected=1]%s[/tornado][/center]"
				% [
					tornado_radius,
					tornado_frequency,
					safe_text
				]
			)

		_:
			animated_label.text = (
				"[center][wave amp=%s freq=%s connected=1]%s[/wave][/center]"
				% [
					wave_amplitude,
					wave_frequency,
					safe_text
				]
			)


func _show_normal_text() -> void:
	if animated_label == null:
		return

	animated_label.text = (
		"[center]%s[/center]"
		% _escape_bbcode(original_text)
	)


func _escape_bbcode(value: String) -> String:
	return value.replace("[", "[lb]")


# Main-menu navigation actions.

func _on_play_button_down() -> void:
	get_tree().change_scene_to_file(
		"res://bgscenes/dialogueintroscreen.tscn"
	)


func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file(
		"res://bgscenes/credits.tscn"
	)


func _on_settings_button_down() -> void:
	get_tree().change_scene_to_file(
		"res://bgscenes/worldmode.tscn"
	)


func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_button_down() -> void:
	get_tree().change_scene_to_file(
		"res://bgscenes/sandboxscreen.tscn"
	)
