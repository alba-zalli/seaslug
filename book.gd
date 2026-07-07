extends Node2D

@export var slug_pages: Array[SlugData] = []
@onready var page_spread: PageSpread = $"../../PageSpread"
@onready var book_anim: AnimatedSprite2D = $"../BookAnim"
@onready var click_area: Area2D = $ClickArea
@onready var close_button: Button = $"./CloseButton"
@onready var name_label = $"../../PageSpread/Container/NameLabel"
@onready var sci_label = $"../../PageSpread/Container/SciNameLabel"
@onready var desc_label = $"../../PageSpread/Container/DescriptionLabel"
@onready var container: VBoxContainer = $"../../PageSpread/Container"
@onready var image_rect = $"../../PageSpread/SlugImage"
@onready var food_rect = $"../../PageSpread/FoodImage"

var base_separation: int

var base_name_size: int
var base_sci_size: int
var base_desc_size: int
var original_image_scale: Vector2
var original_food_scale: Vector2
var original_image_position: Vector2
var original_food_position: Vector2
var base_label: int

var is_open := false
var is_zoomed := false

var original_position: Vector2
var original_scale: Vector2

@export var zoom_scale := 4.0
@export var zoom_duration := 0.4
@export var double_click_wait := 0.3
@export var close_button_offset := Vector2(450, 450) 

# seaslug book page info 
@export var my_data: SlugData

var click_token := 0

var page_original_position: Vector2
var page_original_scale: Vector2

func _ready():
	base_name_size = name_label.get_theme_font_size("font_size")
	base_sci_size = sci_label.get_theme_font_size("font_size")
	base_desc_size = desc_label.get_theme_font_size("normal_font_size")
	base_separation = container.get_theme_constant("separation")
	original_image_scale = image_rect.scale
	original_food_scale = food_rect.scale
	original_position = book_anim.global_position
	original_scale = book_anim.scale
	page_original_position = page_spread.global_position
	page_original_scale = page_spread.scale
	close_button.visible = false
	close_button.pressed.connect(_on_close_button_pressed)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	print("INPUT EVENT FIRED. is_open=", is_open, " is_zoomed=", is_zoomed)
	if not is_open:
		book_anim.play("open")
		is_open = true
		page_spread.visible = false
		await book_anim.animation_finished
		page_spread.display(my_data)
		page_spread.visible = true
		return
	click_token += 1
	if event.double_click:
		_toggle_zoom()
	else:
		var this_token := click_token
		await get_tree().create_timer(double_click_wait).timeout
		if this_token == click_token:
			if is_zoomed:
				_toggle_zoom()
			page_spread.visible = false
			book_anim.play("close")
			is_open = false

func _on_close_button_pressed() -> void:
	print("CLOSE BUTTON PRESSED. is_zoomed=", is_zoomed)
	if is_zoomed:
		_toggle_zoom()

func _toggle_zoom() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	if not is_zoomed:
		var screen_center := get_viewport_rect().size / 2.0
		var offset := page_original_position - original_position
		var target_book_pos := screen_center
		var target_page_pos := screen_center + offset * zoom_scale
		var base_width := container.custom_minimum_size.x
		tween.tween_property(book_anim, "global_position", target_book_pos, zoom_duration)
		tween.tween_property(book_anim, "scale", original_scale * zoom_scale, zoom_duration)
		tween.tween_property(page_spread, "global_position", target_page_pos, zoom_duration)
		# NOTE: no longer scaling page_spread itself — font_size handles the text zoom instead
		tween.tween_property(name_label, "theme_override_font_sizes/font_size", int(base_name_size * zoom_scale), zoom_duration)
		tween.tween_property(sci_label, "theme_override_font_sizes/font_size", int(base_sci_size * zoom_scale), zoom_duration)
		tween.tween_property(desc_label, "theme_override_font_sizes/normal_font_size", int(base_desc_size * zoom_scale), zoom_duration)
		tween.tween_property( container, "theme_override_constants/separation", int(base_separation * zoom_scale), zoom_duration )
		var image_x_offset := -9000 ## OFSET 
		tween.tween_property(
			image_rect,
			"scale",
			original_image_scale * zoom_scale,
			zoom_duration
		)
		tween.tween_property(
	food_rect,
	"position",
	original_food_position + Vector2(-200,0),
	zoom_duration
)
		container.custom_minimum_size.x = 500
		is_zoomed = true
		tween.finished.connect(func():
			close_button.global_position = screen_center - close_button_offset
			close_button.visible = true
		, CONNECT_ONE_SHOT)
	else:
		close_button.visible = false
		tween.tween_property(book_anim, "global_position", original_position, zoom_duration)
		tween.tween_property(book_anim, "scale", original_scale, zoom_duration)
		tween.tween_property(page_spread, "global_position", page_original_position, zoom_duration)
		tween.tween_property(name_label, "theme_override_font_sizes/font_size", base_name_size, zoom_duration)
		tween.tween_property(sci_label, "theme_override_font_sizes/font_size", base_sci_size, zoom_duration)
		tween.tween_property(desc_label, "theme_override_font_sizes/normal_font_size", base_desc_size, zoom_duration)
		tween.tween_property(container,"theme_override_constants/separation",base_separation,zoom_duration)
		container.custom_minimum_size.x = 100
		tween.tween_property(
			image_rect,
			"scale",
			original_image_scale,
			zoom_duration
		)

		tween.tween_property(
			food_rect,
			"scale",
			original_food_scale,
			zoom_duration
		)
		is_zoomed = false

func open_book_to(data: SlugData) -> void:
	visible = true
	page_spread.visible = false
	book_anim.play("open_animation")
	await book_anim.animation_finished
	page_spread.display(data)
	page_spread.visible = true
