extends ColorRect

func _ready():
	WaveManager.register_wave(material)
	print("Registered: ", WaveManager.wave_material)
