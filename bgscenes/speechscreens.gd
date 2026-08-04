extends Node2D

@onready var happy_alba: Sprite2D = $happy_alba
@onready var shocked_alba: Sprite2D = $shocked_alba
@onready var confused_alba: Sprite2D = $confused_alba

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change(sprite_name: String) -> void:
	match sprite_name:
		"happy_alba":
			happy_alba.show()
	match sprite_name:
		"shocked_alba":
			shocked_alba.show()
	match sprite_name:
		"confused_alba":
			confused_alba.show()

func hide_sprite():
	happy_alba.hide()
	shocked_alba.hide()
	confused_alba.hide()
