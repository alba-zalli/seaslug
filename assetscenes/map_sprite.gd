extends Node2D

@onready var wpacific = $WPHighlight
@onready var indian = $IndianHighlight
@onready var red_sea = $RedSeaHighlight

func _ready():
	# Hide all highlights initially
	pacific.visible = false
	indian.visible = false
	red_sea.visible = false

	# Connect WPacific
	$PacificArea.mouse_entered.connect(func(): pacific.visible = true)
	$PacificArea.mouse_exited.connect(func(): pacific.visible = false)

	# Connect Indian
	$IndianArea.mouse_entered.connect(func(): indian.visible = true)
	$IndianArea.mouse_exited.connect(func(): indian.visible = false)

	# Connect Red Sea
	$RedSeaArea.mouse_entered.connect(func(): red_sea.visible = true)
	$RedSeaArea.mouse_exited.connect(func(): red_sea.visible = false)
