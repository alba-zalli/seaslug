extends Node2D
class_name PageSpread

@onready var name_label = $Container/NameLabel
@onready var sci_label = $Container/SciNameLabel
@onready var desc_label = $Container/DescriptionLabel
@onready var image_rect = $RightPageImages/SlugImage
@onready var food_rect = $RightPageImages/FoodImage

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

func _ready():
	pass
