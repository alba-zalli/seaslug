extends Area2D

@onready var page_spread: PageSpread = $"/root/SandboxScreen/Book/PageSpread"
@onready var book_anim: AnimatedSprite2D = $"../BookAnim"
@onready var click_area: Area2D = self
@onready var close_button: Button = $"./CloseButton"
@onready var name_label = $"../../PageSpread/Container/NameLabel"
@onready var sci_label = $"../../PageSpread/Container/SciNameLabel"
@onready var desc_label = $"../../PageSpread/Container/DescriptionLabel"
@onready var container: VBoxContainer = $"../../PageSpread/Container"
@onready var images_holder: Control = $"../../PageSpread/RightPageImages"
@onready var image_rect: TextureRect = $"../../PageSpread/RightPageImages/SlugImage"
@onready var food_rect: TextureRect = $"../../PageSpread/RightPageImages/FoodImage"
@onready var zoom_layer: Control = $"../../PageSpread/ZoomLayer"
@export var zoomed_image_offset := Vector2(-600, 200)  # negative x = left, positive y = down

var base_separation: int

var base_name_size: int
var base_sci_size: int
var base_desc_size: int
var original_image_scale: Vector2
var original_food_scale: Vector2
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

var slug_data := {
	"sapsucker": preload("res://data/sapsucker_data.tres"),
	"caldorid": preload("res://data/caldorid_data.tres"),
}

var click_token := 0

var page_original_position: Vector2
var page_original_scale: Vector2

var image_rect_container_index: int
var food_rect_container_index: int

# shared pivot point for the SlugImage/FoodImage pair, so they scale
# apart from a common center instead of growing into each other
var images_pivot_global: Vector2
var image_rel_offset: Vector2
var food_rel_offset: Vector2

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
	if is_zoomed:
		_toggle_zoom()

func _enter_zoom_layer() -> void:
	image_rect_container_index = image_rect.get_index()
	food_rect_container_index = food_rect.get_index()

	var img_global: Vector2 = image_rect.global_position
	var food_global: Vector2 = food_rect.global_position

	images_holder.remove_child(image_rect)
	images_holder.remove_child(food_rect)
	zoom_layer.add_child(image_rect)
	zoom_layer.add_child(food_rect)

	image_rect.global_position = img_global
	food_rect.global_position = food_global

	# shared center of the pair, computed BEFORE any scaling happens
	images_pivot_global = (img_global + food_global) / 2.0
	image_rel_offset = img_global - images_pivot_global
	food_rel_offset = food_global - images_pivot_global

	print("image pos: ", image_rect.global_position)
	print("food pos: ", food_rect.global_position)

func _exit_zoom_layer() -> void:
	var img_global := image_rect.global_position
	var food_global := food_rect.global_position

	zoom_layer.remove_child(image_rect)
	zoom_layer.remove_child(food_rect)
	images_holder.add_child(image_rect)
	images_holder.add_child(food_rect)
	images_holder.move_child(image_rect, image_rect_container_index)
	images_holder.move_child(food_rect, food_rect_container_index)

	# Avoid a one-frame pop back to the pre-zoom-layer spot
	image_rect.global_position = img_global
	food_rect.global_position = food_global

func _toggle_zoom() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)

	if not is_zoomed:
		_enter_zoom_layer()  # escape the holder before scaling so it can't fight the tween

		var screen_center := get_viewport_rect().size / 2.0 
		var offset := page_original_position - original_position
		var target_book_pos := screen_center
		var target_page_pos := screen_center + offset * zoom_scale
		var base_width := container.custom_minimum_size.x

		tween.tween_property(book_anim, "global_position", target_book_pos, zoom_duration)
		tween.tween_property(book_anim, "scale", original_scale * zoom_scale, zoom_duration)
		tween.tween_property(page_spread, "global_position", target_page_pos, zoom_duration)

		tween.tween_property(name_label, "theme_override_font_sizes/font_size", int(base_name_size * zoom_scale), zoom_duration)
		tween.tween_property(sci_label, "theme_override_font_sizes/font_size", int(base_sci_size * zoom_scale), zoom_duration)
		tween.tween_property(desc_label, "theme_override_font_sizes/normal_font_size", int(base_desc_size * zoom_scale), zoom_duration)
		tween.tween_property(container, "theme_override_constants/separation", int(base_separation * zoom_scale), zoom_duration)

		tween.tween_property(image_rect, "scale", original_image_scale * zoom_scale, zoom_duration)
		tween.tween_property(food_rect, "scale", original_food_scale * zoom_scale, zoom_duration)

		# push the two images apart from their shared center as they grow,
		# so the enlarged sprites don't grow into each other
		var img_target_pos := images_pivot_global + image_rel_offset * zoom_scale + zoomed_image_offset
		var food_target_pos := images_pivot_global + food_rel_offset * zoom_scale + zoomed_image_offset
		tween.tween_property(image_rect, "global_position", img_target_pos, zoom_duration)
		tween.tween_property(food_rect, "global_position", food_target_pos, zoom_duration)

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
		tween.tween_property(container, "theme_override_constants/separation", base_separation, zoom_duration)
		container.custom_minimum_size.x = 100

		tween.tween_property(image_rect, "scale", original_image_scale, zoom_duration)
		tween.tween_property(food_rect, "scale", original_food_scale, zoom_duration)
		tween.tween_property(image_rect, "global_position", images_pivot_global + image_rel_offset, zoom_duration)
		tween.tween_property(food_rect, "global_position", images_pivot_global + food_rel_offset, zoom_duration)

		is_zoomed = false
		tween.finished.connect(_exit_zoom_layer, CONNECT_ONE_SHOT)

func open_book_to(data: SlugData) -> void:
	print("open_book_to received = ", data.slug_name if data else "NULL")
	my_data = data
	if not is_open:
		book_anim.play("open")
		is_open = true
		page_spread.visible = false
		await book_anim.animation_finished
	page_spread.display(my_data)
	page_spread.visible = true
	
func display(data: SlugData) -> void:
	if data == null:
		push_warning("PageSpread.display() called with null data")
		return
	print("PageSpread displaying: ", data.slug_name)
	name_label.text = data.slug_name
	sci_label.text = data.scientific_name
	desc_label.text = data.description
	image_rect.texture = data.image_rect
	food_rect.texture = data.food_rect
