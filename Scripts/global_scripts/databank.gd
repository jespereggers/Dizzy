extends Node

var available_items: Array = ["parchment"]
var max_eggs: int = 2
var game_save: Dictionary = {}

var colors: Dictionary = {
	"black": Color("#000000"),
	"white": Color("#FFFFFF"),
	"red": Color("#68372B"),
	"cyan": Color("#70A4B2"),
	"purple": Color("#6F3D86"),
	"green": Color("#588D43"),
	"yellow": Color("#B8C76F")
}

var maps: Dictionary = {
	"map_1": {
		
		#Etage 0
		Vector2(2,0): {
			"name": "DAS GEFÄNGNIS",
			"path": "res://Maps/map_1/room_17.tscn"
		},
		Vector2(1,0): {
			"name": "DIE WACKELIGE ANGELEGENHEIT",
			"path": "res://Maps/map_1/room_16.tscn"
		},
		Vector2(0,0): {
			"name": "DAS BURGVERLIES",
			"path": "res://Maps/map_1/room_15.tscn"
		},
		Vector2(-1,0): {
			"name": "SCHMUGGLERVERSTECK",
			"path": "res://Maps/map_1/room_14.tscn"
		},
		Vector2(-2,0): {
			"name": "SCHUMRIGER FLUR",
			"path": "res://Maps/map_1/room_13.tscn"
		},
		Vector2(-3,0): {
			"name": "EINSAME HÖHLE",
			"path": "res://Maps/map_1/room_12.tscn"
		},
		Vector2(-4,0): {
			"name": "GEHEIMER KERKER",
			"path": "res://Maps/map_1/room_11.tscn"
		},
		
		#Etage 1
		Vector2(-1,1): {
			"name": "GRABEN UND FALLGATTER",
			"path": "res://Maps/map_1/room_8.tscn"
		},
		Vector2(0,1): {
			"name": "DIE EMPFANGSHALLE",
			"path": "res://Maps/map_1/room_9.tscn"
		},
		Vector2(1,1): {
			"name": "AUSSENPOSTEN",
			"path": "res://Maps/map_1/room_10.tscn"
		},
		
		#Etage 2
		Vector2(-1,2): {
			"name": "DER WESTFLUEGEL",
			"path": "res://Maps/map_1/room_5.tscn"
		},
		Vector2(0,2): {
			"name": "DER BANKETTSAAL",
			"path": "res://Maps/map_1/room_6.tscn"
		},
		Vector2(1,2): {
			"name": "DER OSTFLUEGEL",
			"path": "res://Maps/map_1/room_7.tscn"
		},
		
		#Etage 3
		Vector2(-1,3): {
			"name": "DER WESTFLUEGEL",
			"path": "res://Maps/map_1/room_2.tscn"
		},
		Vector2(0,3): {
			"name": "DAS TREPPENHAUS",
			"path": "res://Maps/map_1/room_3.tscn"
		},
		Vector2(1,3): {
			"name": "DER OSTFLUEGEL",
			"path": "res://Maps/map_1/room_4.tscn"
		},
		
		#Etage 4
		Vector2(0,4): {
			"name": "FINALER RAUM",
			"path": "res://Maps/map_1/room_1.tscn"
		}
	}
}


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()


func load_game():
	if not File.new().file_exists(OS.get_user_data_dir() + "/game_save.dizzy"):
		store_default_game_save()
		
	game_save = tools.load_file("user://game_save.dizzy")


func save_game():
	var world : Dictionary = {}
	
	# Player
	game_save.player.eggs = stats.eggs
	game_save.player.coins = stats.coins
	game_save.player.inventory = stats.inventory
	game_save.player.position = paths.player.position
	
	# Scene
	game_save.scene.current_map = stats.current_map
	game_save.scene.current_room = stats.current_room
	
	tools.save_file("user://game_save.dizzy", game_save)


func store_default_game_save():
	var template: Dictionary = tools.load_file("res://databanks/templates/game_save.json")
	template.player.position = Vector2(128, 118)
	template.scene.current_room = Vector2(0,0)
	template.enviroment.map_1 = {}
	tools.save_file("user://game_save.dizzy", template)
