extends Sprite2D

@export var float_height: float = 12.0
@export var float_speed: float = 2.0

var starting_y: float
var elapsed_time: float = 0.0

func _ready() -> void:
	starting_y = position.y

func _process(delta: float) -> void:
	elapsed_time += delta
	position.y = starting_y + sin(elapsed_time * float_speed) * float_height
