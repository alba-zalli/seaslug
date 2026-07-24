extends Button
# handles all buttons choices in the game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# handles dialogue box choices
func change_to_sandbox():
	get_tree().change_scene_to_file("res://bgscenes/sandboxscreen.tscn")

func change_to_world():
	get_tree().change_scene_to_file("res://bgscenes/bowl.tscn")

# switch from main menu to bowl scene
func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/dialogueintroscreen.tscn")

func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/credits.tscn")
		
func _on_settings_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/settings.tscn")

# switch from bowl scene to main menu
func _on_back_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/main_menu.tscn")

# quit game
func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_sandbox_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/sandboxscreen.tscn")

func _on_world_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/worldmode.tscn")

func _on_windowed_button_down() -> void:
	pass
