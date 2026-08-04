extends TextureButton

@export var music_on_icon: Texture2D
@export var music_off_icon: Texture2D


func _ready() -> void:
	custom_minimum_size = Vector2(40, 40)
	size = Vector2(40, 40)
	pressed.connect(_on_pressed)

	MusicManager.mute_changed.connect(
		_on_music_mute_changed
	)

	_update_icon(MusicManager.is_muted)


func _on_pressed() -> void:
	MusicManager.toggle_mute()


func _on_music_mute_changed(muted: bool) -> void:
	_update_icon(muted)


func _update_icon(muted: bool) -> void:
	texture_normal = (
		music_off_icon
		if muted
		else music_on_icon
	)

	tooltip_text = (
		"Turn music on"
		if muted
		else "Mute music"
	)
