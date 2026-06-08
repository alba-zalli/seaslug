extends Sprite2D

func _ready() -> void:
	var target_size = get_parent().ball_size*2
	var texture_size = texture.get_size().x
	scale = Vector2.ONE * (target_size / texture_size)
	offset = texture.get_size() / 2  
