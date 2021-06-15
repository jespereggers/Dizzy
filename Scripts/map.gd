extends Node2D

onready var root: Node2D = get_parent()
signal room_entered_tree

func _ready():
	yield(signals, "backend_is_ready")
	update_map()


func update_map():
	clean_maps()
	var map: Node2D = load(databank.maps[stats.current_map][stats.current_room].path).instance()
	map.connect("tree_entered", self, "_on_map_enters_tree", [map])
	call_deferred("add_child", map)


func _on_map_enters_tree(map_instance: Node2D):
	emit_signal("room_entered_tree")
	yield(get_tree().create_timer(0.2), "timeout")
	if map_instance == null:
		return
	for node in map_instance.get_children():
		if node.get_class() == "Area2D":
			node.monitoring = true


func add(properties: Dictionary):
	var object
	
	match properties.type:
		"item":
			object = load("res://templates/item.tscn").instance()
			object.set_properties(properties)
			object.load_template()
			object.update_pos()
	tools.add_object(object)
	
	for node in get_children():
		if "room" in node.name:
			node.get_node("objects").add_child(object)
			break


func remove(object):
	for node in get_children():
		if "room" in node.name:
			node.get_node("objects").remove_child(object)
			break


func clean_maps():
	for room in get_children():
		if str(room.filename) != databank.maps[stats.current_map][stats.current_room].path and room.name != "user_interface":
			room.queue_free()


func respawn_player():
	for child in get_children():
		if "room_" in child.name:
			if child.has_node("respawn_point"):
				var new_pos: Vector2 = child.get_node("respawn_point").position 
				new_pos += Vector2(8, 49)
				root.player.position = new_pos
			else:
				root.player.position = get_viewport_rect().size / 2
	
	signals.emit_signal("player_respawned")
