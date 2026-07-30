# configures existing slug nodes (already in the scene, e.g. on your
# dialogue intro screen) to orbit a target node as a staggered halo.
extends Node2D

@export var target_path: NodePath                     # the face/head node the halo circles
@export var slug_nodes: Array[CharacterBody2D] = [$HaloManager/Paradisa]

@export var radius_x := 60.0
@export var radius_y := 20.0
@export var tilt := -0.15
@export var orbit_speed := 1.0
@export var slug_scale := 0.02                         # match whatever scale your fish.gd normally applies


func _ready() -> void:
	print("slug_nodes: ", slug_nodes)
	print("target_path: ", target_path, " resolves to: ", get_node_or_null(target_path)) 
	if slug_nodes.is_empty():
		push_warning("slug_halo_manager: no slug_nodes assigned")
		return

	var target_node := get_node_or_null(target_path)
	if target_node == null:
		push_warning("slug_halo_manager: target_path not found")
		return
	print("target global_position: ", target_node.global_position)
	print("Paradisa global_position: ", slug_nodes[0].global_position)
	var count := slug_nodes.size()
	for i in range(count):
		var slug := slug_nodes[i]
		if slug == null:
			continue

		# swap in the halo orbit script (node is already in the tree, so
		# this does NOT re-trigger _ready -- we call setup() ourselves below)
		slug.set_script(load("res://assetscenes/slugscenes/circle_slug_swimming.gd"))

		slug.target_path = slug.get_path_to(target_node)
		slug.radius_x = radius_x
		slug.radius_y = radius_y
		slug.tilt = tilt
		slug.orbit_speed = orbit_speed
		slug.scale_multiplier = slug_scale

		# stagger evenly around the ellipse, alternate direction for variety
		slug.phase_offset = (TAU / count) * i
		slug.clockwise = (i % 2 == 0)

		slug.setup()
