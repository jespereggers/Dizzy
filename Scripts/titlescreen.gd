extends Control

var current_menue: String


func _ready():
	if get_tree().current_scene.name == "titlescreen":
		databank.load_databanks()
		load_settings()
		load_menu("main")


func load_settings():
	# Sound
	var master_sound = AudioServer.get_bus_index("Master")
	if databank.settings.sound == true:
		AudioServer.set_bus_mute(master_sound, false)
	else:
		AudioServer.set_bus_mute(master_sound, true)
	
	# Language
	match databank.settings.language:
		"german":
			TranslationServer.set_locale("de")
		"english":
			TranslationServer.set_locale("en")


func load_menu(menu_name: String):
	match get_tree().current_scene.name:
		"titlescreen":
			$main.set("custom_constants/separation", 34)
		"world":
			$main.set("custom_constants/separation", 10)
			
	current_menue = menu_name
	for button in $main.get_children():
		button.queue_free()
		yield(button, "tree_exited")
		
	for button in databank.titlescreen[menu_name]:
		if button[0] == "play" and get_tree().current_scene.name == "world":
			button = ["resume"]
			
		var button_template = get_button_instance(button[0])
		if button.size() > 1:
			button_template.connect("pressed", self, "load_menu", [button[1]])
		else:
			button_template.connect("pressed", self, "_on_setting_pressed", [button[0]])

			match button[0]:
				"resume":
					if not File.new().file_exists(OS.get_user_data_dir() + "/game_save.dizzy"):
						button_template.disable()
				"english":
					if databank.settings.language == "english":
						button_template.disable()
				"german":
					if databank.settings.language == "german":
						button_template.disable()
				"sound on":
					if databank.settings.sound == true:
						button_template.disable()
				"sound off":
					if databank.settings.sound == false:
						button_template.disable()
	
		$main.add_child(button_template)
		
	for button in $main.get_children():
		if button.get_index() - 1 >= 0:
			button.focus_neighbour_left = $main.get_child(button.get_index() - 1).get_path()
			button.focus_neighbour_top = $main.get_child(button.get_index() - 1).get_path()
		else:
			button.focus_neighbour_left = $main.get_child($main.get_child_count() - 1).get_path()
			button.focus_neighbour_top = $main.get_child($main.get_child_count() - 1).get_path()
	
		if button.get_index() + 1 <= $main.get_child_count() - 1:
			button.focus_neighbour_right = $main.get_child(button.get_index() + 1).get_path()
			button.focus_neighbour_bottom = $main.get_child(button.get_index() + 1).get_path()
		else:
			button.focus_neighbour_right = $main.get_child(0).get_path()
			button.focus_neighbour_bottom = $main.get_child(0).get_path()
	
	if get_tree().current_scene.name == "world":
		for button in $main.get_children():
			if button.get_index() != 0 and button.get_index() < $main.get_child_count() - 1:
				button.change_background(true)
			if button.get_index() == $main.get_child_count() - 1:
				button.show_behind_parent = true
	
	for button in $main.get_children():
		if button.get_class() == "Button" and button.visible:
			button.grab_focus()
			break

	if menu_name == "on_credits":
		var credit_instance = load("res://Scenes/templates/credits.tscn").instance()
		$main.add_child(credit_instance)
		$main.move_child(credit_instance, 0)


func get_button_instance(button_name: String) -> Button:
	var button: Button = load("res://Scenes/templates/settings_button.tscn").instance() #!
	button.load_template(button_name, get_tree().current_scene.name)
	return button


func _on_setting_pressed(button_name: String):
	match button_name:
		"new game":
			get_tree().paused = false
			databank.store_default_game_save()
			get_tree().change_scene("res://Scenes/world.tscn")
		"resume":
			if get_tree().current_scene.name == "world":
				get_tree().paused = false
				get_parent().hide()
				return
			get_tree().paused = false
			get_tree().change_scene("res://Scenes/world.tscn")
		"german":
			databank.settings.language = "german"
			load_menu("on_language")
		"english":
			databank.settings.language = "english"
			load_menu("on_language")
		"sound on":
			databank.settings.sound = true
			load_menu("on_sound")
		"sound off":
			databank.settings.sound = false
			load_menu("on_sound")
		"exit":
			databank.save_setttings()
			if get_tree().current_scene.name == "world":
				databank.save_game()
			yield(get_tree().create_timer(0.2), "timeout")
			get_tree().quit()
		
	load_settings()


func _on_titlescreen_visibility_changed():
	if is_visible_in_tree():
		load_menu("main")
