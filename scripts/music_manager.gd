extends Node

signal mute_changed(is_muted: bool)
signal track_changed(track_index: int)

const SETTINGS_PATH := "user://audio_settings.cfg"
const MUSIC_BUS_NAME := "Music"

var playlist: Array[AudioStream] = [
	preload("res://music/depths of the sea.wav"),
	preload("res://music/ocean jazz.wav"),
	preload("res://music/waves.wav"),
]

var current_track_index: int = 0
var is_muted: bool = false

var music_player: AudioStreamPlayer


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = MUSIC_BUS_NAME
	add_child(music_player)

	music_player.finished.connect(_on_music_finished)

	_load_audio_settings()
	_apply_mute_state()

	if not playlist.is_empty():
		play_track(current_track_index)


func play_track(index: int) -> void:
	if playlist.is_empty():
		push_warning("MusicManager playlist is empty.")
		return

	current_track_index = wrapi(index, 0, playlist.size())

	var selected_track := playlist[current_track_index]

	if selected_track == null:
		push_warning(
			"Music track %d is missing." % current_track_index
		)
		play_next_track()
		return

	music_player.stop()
	music_player.stream = selected_track
	music_player.play()

	track_changed.emit(current_track_index)


func play_next_track() -> void:
	if playlist.is_empty():
		return

	play_track(current_track_index + 1)


func play_previous_track() -> void:
	if playlist.is_empty():
		return

	play_track(current_track_index - 1)


func restart_current_track() -> void:
	if playlist.is_empty():
		return

	play_track(current_track_index)


func stop_music() -> void:
	music_player.stop()


func resume_music() -> void:
	if playlist.is_empty():
		return

	if not music_player.playing:
		music_player.play()


func set_muted(muted: bool) -> void:
	is_muted = muted
	_apply_mute_state()
	_save_audio_settings()

	mute_changed.emit(is_muted)


func toggle_mute() -> bool:
	set_muted(not is_muted)
	return is_muted


func _apply_mute_state() -> void:
	var music_bus_index := AudioServer.get_bus_index(
		MUSIC_BUS_NAME
	)

	if music_bus_index == -1:
		push_error(
			'Audio bus "%s" was not found.' % MUSIC_BUS_NAME
		)
		return

	AudioServer.set_bus_mute(
		music_bus_index,
		is_muted
	)


func _on_music_finished() -> void:
	play_next_track()


func _save_audio_settings() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"audio",
		"music_muted",
		is_muted
	)

	var error := config.save(SETTINGS_PATH)

	if error != OK:
		push_warning(
			"Could not save audio settings. Error: %s"
			% error
		)


func _load_audio_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	if error != OK:
		is_muted = false
		return

	is_muted = config.get_value(
		"audio",
		"music_muted",
		false
	) 
