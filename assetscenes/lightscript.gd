extends DirectionalLight2D

@export var sway_degrees: float = 4.0
@export var sway_speed: float = 0.3
@export var energy_flicker: float = 0.08

var base_rotation: float
var base_energy: float
var t := 0.0

func _ready():
	base_rotation = rotation
	base_energy = energy

func _process(delta):
	t += delta
	rotation = base_rotation + sin(t * sway_speed) * deg_to_rad(sway_degrees)
	energy = base_energy + sin(t * sway_speed * 2.3) * energy_flicker
