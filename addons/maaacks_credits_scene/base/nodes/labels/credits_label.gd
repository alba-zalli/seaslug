@tool
extends RichTextLabel
## Parses an attribution file written in Markdown and displays it as BBCode.


const HEADING_WITH_FONT := (
	"$1[font=\"%s\"][font_size=%d]$2[/font_size][/font]"
)

const BOLD_HEADING_WITH_FONT := (
	"$1[b][font=\"%s\"][font_size=%d]$2[/font_size][/font][/b]"
)

const HEADING_WITHOUT_FONT := (
	"$1[font_size=%d]$2[/font_size]"
)

const BOLD_HEADING_WITHOUT_FONT := (
	"$1[b][font_size=%d]$2[/font_size][/b]"
)


## The path to the attribution file in Markdown format.
@export_file("*.md") var attribution_file_path: String

## Update the label automatically when the node becomes ready.
@export var auto_update: bool = true


@export_group("Heading Fonts")

## Font used by level-one headings.
@export var h1_font: Font

## Font used by level-two headings.
@export var h2_font: Font


@export_group("Font Sizes")

## Size used for regular paragraph text.
@export var normal_font_size: int = 20

## Heading sizes.
@export var h1_font_size: int = 38
@export var h2_font_size: int = 30
@export var h3_font_size: int = 28
@export var h4_font_size: int = 24
@export var h5_font_size: int = 22
@export var h6_font_size: int = 20

## Bold all headings.
@export var bold_headings: bool = true


@export_group("Image Sizes")

## Maximum image width. Use 0 for the original width.
@export var max_image_width: int = 0

## Maximum image height. Use 0 for the original height.
@export var max_image_height: int = 0


@export_group("Extra Options")

## Prevent images from being loaded.
@export var disable_images: bool = false

## Display link text without turning it into a clickable URL.
@export var disable_urls: bool = false

## Prevent URLs from opening in the browser.
@export var disable_opening_links: bool = false


func load_file(file_path: String) -> String:
	if file_path.is_empty():
		push_warning("No attribution file path was provided.")
		return ""

	if not FileAccess.file_exists(file_path):
		push_warning(
			"Attribution file does not exist: %s"
			% file_path
		)
		return ""

	var file_string := FileAccess.get_file_as_string(file_path)
	var file_error := FileAccess.get_open_error()

	if file_error != OK:
		push_warning(
			"Could not open attribution file. Error: %s"
			% error_string(file_error)
		)
		return ""

	return file_string


func regex_replace_imgs(credits: String) -> String:
	var regex := RegEx.new()
	var match_string := "!\\[([^\\]]*)\\]\\(([^\\)]*)\\)"
	var replace_string := ""

	if not disable_images:
		replace_string = "res://$2[/img]"

		if max_image_width > 0 and max_image_height > 0:
			replace_string = (
				"[img=%dx%d]"
				% [max_image_width, max_image_height]
			) + replace_string

		elif max_image_width > 0:
			replace_string = (
				"[img=%d]"
				% max_image_width
			) + replace_string

		else:
			replace_string = "[img]" + replace_string

	var compile_error := regex.compile(match_string)

	if compile_error != OK:
		push_warning(
			"Could not compile image regular expression."
		)
		return credits

	return regex.sub(
		credits,
		replace_string,
		true
	)


func regex_replace_urls(credits: String) -> String:
	var regex := RegEx.new()
	var match_string := "\\[([^\\]]*)\\]\\(([^\\)]*)\\)"
	var replace_string := "$1"

	if not disable_urls:
		replace_string = "[url=$2]$1[/url]"

	var compile_error := regex.compile(match_string)

	if compile_error != OK:
		push_warning(
			"Could not compile URL regular expression."
		)
		return credits

	return regex.sub(
		credits,
		replace_string,
		true
	)


func regex_replace_titles(credits: String) -> String:
	var heading_font_sizes: Array[int] = [
		h1_font_size,
		h2_font_size,
		h3_font_size,
		h4_font_size,
		h5_font_size,
		h6_font_size
	]

	for index in range(heading_font_sizes.size()):
		var heading_level := index + 1
		var heading_font_size := heading_font_sizes[index]
		var heading_font := _get_heading_font(heading_level)

		var regex := RegEx.new()

		# Matches Markdown headings from # through ######.
		# The negative lookahead prevents an H1 expression from
		# accidentally matching the beginning of an H2 heading.
		var match_string := (
			"(?m)(^|[^#])#{%d}(?!#)\\s+([^\\n\\r]*)"
			% heading_level
		)

		var compile_error := regex.compile(match_string)

		if compile_error != OK:
			push_warning(
				"Could not compile heading expression for h%d."
				% heading_level
			)
			continue

		var replace_string := _make_heading_replacement(
			heading_font,
			heading_font_size
		)

		credits = regex.sub(
			credits,
			replace_string,
			true
		)

	return credits


func _get_heading_font(heading_level: int) -> Font:
	match heading_level:
		1:
			return h1_font

		2:
			return h2_font

		_:
			return null


func _make_heading_replacement(
	heading_font: Font,
	heading_font_size: int
) -> String:
	if heading_font != null:
		var font_path := heading_font.resource_path

		if not font_path.is_empty():
			if bold_headings:
				return (
					BOLD_HEADING_WITH_FONT
					% [font_path, heading_font_size]
				)

			return (
				HEADING_WITH_FONT
				% [font_path, heading_font_size]
			)

		push_warning(
			"Heading font has no saved resource path. "
			+ "Save or import it as a project font resource."
		)

	if bold_headings:
		return (
			BOLD_HEADING_WITHOUT_FONT
			% heading_font_size
		)

	return (
		HEADING_WITHOUT_FONT
		% heading_font_size
	)


func _update_text_from_file() -> void:
	var file_text := load_file(attribution_file_path)

	if file_text.is_empty():
		text = ""
		return

	file_text = _remove_attribution_title(file_text)
	file_text = regex_replace_imgs(file_text)
	file_text = regex_replace_urls(file_text)
	file_text = regex_replace_titles(file_text)

	bbcode_enabled = true
	text = file_text

	add_theme_font_size_override(
		"normal_font_size",
		normal_font_size
	)

	scroll_following = false
	scroll_following_visible_characters = false

	call_deferred("_reset_scroll_to_top")


func _remove_attribution_title(file_text: String) -> String:
	var first_line_end := file_text.find("\n")

	if first_line_end < 0:
		if file_text.strip_edges().to_upper() == "ATTRIBUTION":
			return ""

		return file_text

	var first_line := file_text.left(first_line_end).strip_edges()

	if first_line.to_upper() == "ATTRIBUTION":
		return file_text.substr(first_line_end + 1)

	return file_text


func _reset_scroll_to_top() -> void:
	scroll_to_line(0)

	var scroll_bar := get_v_scroll_bar()

	if is_instance_valid(scroll_bar):
		scroll_bar.value = 0.0


func set_file_path(file_path: String) -> void:
	attribution_file_path = file_path
	_update_text_from_file()


func _on_meta_clicked(meta: Variant) -> void:
	if disable_opening_links:
		return

	var link := str(meta)

	if not (
		link.begins_with("https://")
		or link.begins_with("http://")
	):
		return

	var open_error := OS.shell_open(link)

	if open_error != OK:
		push_warning(
			"Could not open link: %s"
			% link
		)


func _ready() -> void:
	bbcode_enabled = true
	scroll_following = false
	scroll_following_visible_characters = false

	if not meta_clicked.is_connected(_on_meta_clicked):
		meta_clicked.connect(_on_meta_clicked)

	if auto_update:
		_update_text_from_file()
