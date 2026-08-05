extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("wave")
