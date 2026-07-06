extends Node2D
class_name PageSpread

@onready var name_label = $Container/NameLabel
@onready var sci_label = $Container/SciNameLabel
@onready var desc_label = $Container/DescriptionLabel
@onready var image_rect = $SlugImage

func display(data: SlugData) -> void:
	name_label.text = data.slug_name
	sci_label.text = data.scientific_name
	desc_label.text = data.description
	image_rect.texture = data.image

func _ready():
	print("Container children: ")
	for child in $Container.get_children():
		print(" - ", child.name)
