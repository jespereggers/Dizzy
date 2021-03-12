extends CanvasLayer

onready var coins_label: Label = $coins_label
onready var egg_list: HBoxContainer = $egg_list
onready var room_label: Label = $room_label


func _ready():
	signals.connect("coins_changed", self, "update_coins")
	signals.connect("eggs_changed", self, "update_eggs")
	yield(signals, "backend_is_ready")
	update_display()


func update_display():
	set_room_name_to(databank.maps[stats.current_map][stats.current_room].name)
	set_coins_to(stats.coins)
	set_eggs_to(stats.eggs)


func set_room_name_to(new_room_name: String):
	room_label.text = new_room_name


func update_coins():
	set_coins_to(stats.coins)

func set_coins_to(amount: int):
	coins_label.text = str(amount)
	for i in abs(coins_label.text.length() - 3):
		coins_label.text = "0" + coins_label.text


func update_eggs():
	set_eggs_to(stats.eggs)

func set_eggs_to(amount: int):
	for egg in egg_list.get_children():
		egg.visible = (int(egg.name.replace("egg_", "")) <= amount)
