extends Node2D

@export var slug_pages: Array[SlugData] = []
@onready var page_spread: PageSpread = $"../../PageSpread"
@onready var book_anim: AnimatedSprite2D = $"../BookAnim"
@onready var click_area: Area2D = $ClickArea
@onready var close_button: Button = $"./CloseButton"

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

func _ready():
	print("my_data = ", my_data)
	print("my_data = ", my_data)
	print("page_spread = ", page_spread)
	original_position = book_anim.global_position
	original_scale = book_anim.scale
	close_button.visible = false
	close_button.pressed.connect(_on_close_button_pressed)
	original_position = book_anim.global_position
	original_scale = book_anim.scale
	close_button.visible = false
	close_button.pressed.connect(_on_close_button_pressed)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
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

func _toggle_zoom() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)

	if not is_zoomed:
		var screen_center := get_viewport_rect().size / 2.0
		tween.tween_property(book_anim, "global_position", screen_center, zoom_duration)
		tween.tween_property(book_anim, "scale", original_scale * zoom_scale, zoom_duration)
		is_zoomed = true

		# Show and position the close button once the tween finishes.
		tween.finished.connect(func():
			close_button.global_position = screen_center - close_button_offset
			close_button.visible = true
		, CONNECT_ONE_SHOT)
	else:
		close_button.visible = false
		tween.tween_property(book_anim, "global_position", original_position, zoom_duration)
		tween.tween_property(book_anim, "scale", original_scale, zoom_duration)
		is_zoomed = false

func open_book_to(data: SlugData) -> void:
	visible = true
	page_spread.visible = false
	book_anim.play("open_animation")
	await book_anim.animation_finished
	page_spread.display(data)
	page_spread.visible = true
