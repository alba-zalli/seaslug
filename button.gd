extends Button

#handles switching scenes?
#could probably put this all into one file wiht quit idk whats happening lowk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_down() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")
		
func _on_settings_button_down() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")
