extends Node

var wave_material: ShaderMaterial = null

func register_wave(material: ShaderMaterial) -> void:
	wave_material = material

func get_surface_y_px(x_px: float) -> float:
	if wave_material == null:
		return DisplayServer.screen_get_size().y  # fallback: treat whole screen as "underwater"

	var screen_size = DisplayServer.screen_get_size()
	var liquid_level = wave_material.get_shader_parameter("liquid_level")
	var amplitude = wave_material.get_shader_parameter("wave_amplitude")
	var frequency = wave_material.get_shader_parameter("wave_frequency")
	var speed = wave_material.get_shader_parameter("wave_speed")

	var uv_x = x_px / screen_size.x
	var t = Time.get_ticks_msec() / 1000.0

	var wave = sin(uv_x * frequency + t * speed) * amplitude
	var surface_uv_y = (1.0 - liquid_level) + wave

	return surface_uv_y * screen_size.y
