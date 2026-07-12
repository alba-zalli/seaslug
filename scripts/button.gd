extends Button

#handles switching scenes?
#could probably put this all into one file wiht quit idk whats happening lowk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# switch from main menu to bowl scene
func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://bgscenes/sandboxscreen.tscn")

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
