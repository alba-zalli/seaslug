extends TextureButton

@export var music_on_icon: Texture2D
@export var music_off_icon: Texture2D


func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	custom_minimum_size = Vector2(40, 40)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

	if not MusicManager.mute_changed.is_connected(
		_on_music_mute_changed
	):
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
