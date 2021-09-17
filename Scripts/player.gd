extends KinematicBody2D

onready var animations: AnimationPlayer = $animations
onready var texture: Sprite = $texture
onready var state_machine: Node = $state_machine
onready var collision: CollisionShape2D = $collision
onready var item_detector: Area2D = $item_detector

var motion: Vector2 = Vector2()
var unlocked: bool = false
var action: Array = ["idle"]
var locked: bool = false
var is_on_leaderbox: bool = false
var action_start_pos: Vector2 = Vector2(0,0)
var is_autojumping: bool = false

# Movement
var GRAVITY: float = 2.2

var JUMP_SPEED: int = 90
var MAX_JUMP_SPEED: int = 455
var JUMP_FORCE: int = 95

var WALK_SPEED: int = 20
var MAX_WALK_SPEED: int = 40

var UP: Vector2 = Vector2(0, -1)

func _ready():
	yield(signals, "backend_is_ready")
	self.position = data.game_save.player.position
	
	if signals.connect("room_changed", self, "_on_room_changed") != OK:
		print("Error occured when trying to establish a connection")
	if signals.connect("player_died", self, "_on_player_died") != OK:
		print("Error occured when trying to establish a connection")
	if signals.connect("player_respawned", self, "_on_player_respawned") != OK:
		print("Error occured when trying to establish a connection")


func _on_player_respawned():
	locked = true
	action = ["idle"]
	#self.position.y += get_height()
	animations.play_backwards("death")
	yield(get_tree().create_timer(1.45), "timeout")
	animations.play("idle")
	$texture.show()
	$dizzy_death.hide()
	set_physics_process(true)
	locked = false


func _on_room_changed():
	if animations.current_animation in ["idle", "walk"] and not is_on_floor():
		self.position.y -= get_height()


func _on_player_died(collision_object):
	audio.play("dead")
	# Play Death-animation
	set_physics_process(false)
	self.animations.play("death")
	yield(animations, "animation_finished")
	set_physics_process(true)

	paths.ui.death.start(collision_object)


func _physics_process(_delta):
	var previous_action: Array = action
	
	motion.y += GRAVITY

	motion.y = clamp(motion.y, -MAX_JUMP_SPEED, MAX_JUMP_SPEED)
	motion.x = clamp(motion.x, -MAX_WALK_SPEED, MAX_WALK_SPEED)
	
	if is_on_floor():
		is_autojumping = false
		
	#if is_on_leaderbox and "walk" in action and is_on_wall():
# warning-ignore:integer_division
	#	motion.y = -JUMP_SPEED / 3
		
	if not locked or unlocked:
		if can_autojump():
			is_autojumping = true
# warning-ignore:integer_division
			motion.y = -JUMP_SPEED*1.2
			unlocked = true
			$unlocked_cooldown.start(1.0)
		elif motion.y < 0 and not feet_is_on_wall() and is_autojumping:
			motion.y = lerp(motion.y, 0, 0.15)

		if is_on_floor() or unlocked:
			action = []
			if Input.is_action_pressed("walk_left"):
				action = ["walk", "left"]
			elif Input.is_action_pressed("walk_right"):
				action = ["walk", "right"]
				
			if Input.is_action_pressed("jump"):
				if Input.is_action_pressed("walk_left"):
					action = ["jump", "left"]
				elif Input.is_action_pressed("walk_right"):
					action = ["jump", "right"]
				elif action != ["salto"]:
					Input.action_press("salto")
					action = ["salto"]
						
			elif Input.is_action_pressed("salto"):
				action = ["salto"]
				
			if action == []:
				if previous_action[0] == "walk" and action_start_pos.distance_to(self.position) > 4:
					action = ["idle"]
				else:
					action = previous_action
	
	if not is_on_wall():
		texture.flip_h = motion.x < 0
	
	# Register start_pos of new action
	if action[0] == "walk" and Input.is_action_just_pressed("walk_" + action[1]):
		action_start_pos = self.position
	
	update_motion()
	state_machine.update_state(action[0])
	motion = move_and_slide(motion, UP)


func update_motion():
	# action[0] -> action_name
	# action[1] -> action_direction
	
	match action[0]:
		"idle":
			motion.x = 0
			
		"walk":
			if action[1] == "left":
				motion.x -= WALK_SPEED
			else:
				motion.x += WALK_SPEED
				
		"jump":
			if is_on_floor() and Input.is_action_pressed("jump"):
				motion.y -= JUMP_FORCE
			if action[1] == "right":
				motion.x += WALK_SPEED * 0.8
			else:
				motion.x -= WALK_SPEED * 0.8
				
		"salto":
			if is_on_floor() and Input.is_action_pressed("salto"):
				motion.y -= JUMP_FORCE
				Input.action_release("salto")
			motion.x = 0
			
		"climb":
			pass


func get_height() -> float:
	if $raycast.is_colliding():
		return self.position.distance_to($raycast.get_collision_point())
	return 99.99


func can_autojump() -> bool:
	if is_on_wall() and is_on_floor():
		if texture.flip_h:
			# Check autojump on left side
			if not $raycast_left_middle.is_colliding() and $raycast_left_bottom.is_colliding():
				return true
		else:
			# Check autojump on right side
			if not $raycast_right_middle.is_colliding() and $raycast_right_bottom.is_colliding():
				return true
	return false


func feet_is_on_wall() -> bool:
	if is_on_wall() and is_on_floor():
		if texture.flip_h:
			# Check autojump on left side
			if $raycast_left_bottom.is_colliding():
				return true
		else:
			# Check autojump on right side
			if $raycast_right_bottom.is_colliding():
				return true
	return false


func _on_unlocked_cooldown_timeout():
	unlocked = false


func _on_ticks_timeout():
	if is_on_floor() and not stats.current_room in data.game_save.visited_rooms:
		data.game_save.visited_rooms.append(stats.current_room)
		signals.emit_signal("new_room_touched")
