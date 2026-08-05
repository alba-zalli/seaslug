extends Sprite2D

@export var water_rect: Control
@export var water_material: ShaderMaterial
@export var boat_position := Vector2(0.2, 0.5)  # moved left
@export var tilt_strength := 0.6
@export var tilt_smoothing := 8.0
@export var show_boat := true

var _current_tilt := 0.0

func _ready() -> void:
	if water_rect == null:
		push_error("Boat: water_rect is not assigned in the Inspector")
		return
	water_material = water_rect.material as ShaderMaterial
	if water_material == null:
		push_error("Boat: water_rect has no ShaderMaterial assigned")

func _process(delta: float) -> void:
	if water_rect == null or water_material == null:
		return

	var amplitude: float = float(water_material.get_shader_parameter("wave_amplitude"))
	var frequency: float = float(water_material.get_shader_parameter("wave_frequency"))
	var speed: float = float(water_material.get_shader_parameter("wave_speed"))
	var gravity_angle: float = float(water_material.get_shader_parameter("gravity_angle"))
	var float_offset: float = float(water_material.get_shader_parameter("boat_float_offset"))
	var t := Time.get_ticks_msec() / 1000.0
	water_material.set_shader_parameter("time_override", t)

	# keep the shader's shadow locked to this sprite's actual position
	water_material.set_shader_parameter("boat_position", boat_position)
	water_material.set_shader_parameter("show_boat", show_boat)

	var rect_size: Vector2 = water_rect.size
	var centered_pos := boat_position - Vector2(0.5, 0.5)
	var rotated := centered_pos.rotated(-gravity_angle) + Vector2(0.5, 0.5)
	var wave := sin(rotated.x * frequency + speed * t) * amplitude
	var wave_uv := boat_position + Vector2(0.0, wave + float_offset)
	position = wave_uv * rect_size

	var slope := amplitude * frequency * cos(rotated.x * frequency + speed * t)
	var target_tilt := atan(slope) * tilt_strength
	_current_tilt = lerp_angle(_current_tilt, target_tilt, delta * tilt_smoothing)
	rotation = _current_tilt
