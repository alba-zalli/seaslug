extends Button

# Handles all button choices in the game.


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


# Handles dialogue box choices.
func change_to_sandbox() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/sandboxscreen.tscn"
	)


func change_to_world() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/bowl.tscn"
	)


# Switch from main menu to dialogue intro.
func _on_play_button_down() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/dialogueintroscreen.tscn"
	)


func _on_credits_button_down() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/credits.tscn"
	)


func _on_settings_button_down() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/worldmode.tscn"
	)


# Switch back to the main menu.
func _on_back_button_down() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/bettermainmenu.tscn"
	)


# Quit the game.
func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_windowed_button_down() -> void:
	pass


func _on_button_down() -> void:
	SceneLoader.load_scene(
		"res://bgscenes/sandboxscreen.tscn"
	)
