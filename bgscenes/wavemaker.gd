extends ColorRect

func _ready():
	WaveManager.register_wave(material)
	print("Registered: ", WaveManager.wave_material)
	material.set_shader_parameter("rect_size", size)  # or texture.get_size() for a Sprite2D
	resized.connect(func(): material.set_shader_parameter("rect_size", size))
