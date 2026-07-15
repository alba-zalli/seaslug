extends Area2D

@export var highlight: Sprite2D

func _ready():
	highlight.visible = false
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)

func _on_enter():
	print("Entered")
	highlight.visible = true

func _on_exit():
	print("Exited")
	highlight.visible = false
