extends Node

const SPAWN_RADIUS = 350 # viewport width is 640, use radius circle of 320 + a lil buffer to ensure enemy doesn't spawn in the viewport

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var ghost_enemy_scene: PackedScene
@export var arena_time_manager: Node
@export var enemy_position_field: Node2D
@export var game_camera: Camera2D


var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var enemy_offset = 10 # this is > the size of all enemies collision diameter


func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = $Timer.wait_time


func _on_timer_timeout():
	$Timer.start()
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var enemy_scene = enemy_table.pick_item()
	var enemy = enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()


func _on_arena_time_manager_arena_difficulty_increased(arena_difficulty):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, .7)
	$Timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 3:
		enemy_table.add_item(ghost_enemy_scene, 5)
	
	elif arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_scene, 2)


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	if player == null:
		return Vector2.ZERO
		
	#var spawn_position = Vector2.ZERO
	#var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	#var enemy_collision_offset = 20 * random_direction #20 is enough to account for current collision shapes in game w radius of up to 10px
	#for i in 4:
		#spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		#var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + enemy_collision_offset, 1)
		#var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
#
		#if result.is_empty():
			#break
		#else:
			#random_direction = random_direction.rotated(.25 * TAU)
	
	var spawn_position = Vector2.ZERO
	var enemy_position_field_start: Vector2 = enemy_position_field.get_field_position()
	var enemy_position_field_end: Vector2 = enemy_position_field.get_field_end()
	var left_spawn_limit = enemy_position_field_start.x
	var right_spawn_limit = enemy_position_field_end.x
	var top_spawn_limit = enemy_position_field_start.y
	var bottom_spawn_limit = enemy_position_field_end.y

	# find bounds of camera based on camera center position
	var camera_center = game_camera.get_screen_center_position()
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var top_viewport = camera_center.y - (viewport_rect.size.y / 2)
	var bottom_viewport = camera_center.y + (viewport_rect.size.y / 2)
	var left_viewport = camera_center.x - (viewport_rect.size.x / 2)
	var right_viewport = camera_center.x + (viewport_rect.size.x / 2)

	var spawn_x
	var spawn_y
	
	var spawn_left = false
	var spawn_right = false
	var spawn_top = false
	var spawn_bot = false
	
	if left_viewport > left_spawn_limit:
		spawn_left = true
		
	if right_viewport < right_spawn_limit:
		spawn_right = true
	
	if spawn_left && spawn_right:
		if randi_range(0, 1):
			spawn_x = randi_range(left_spawn_limit + enemy_offset, left_viewport - enemy_offset)
		else:
			spawn_x = randi_range(right_spawn_limit - enemy_offset, right_viewport + enemy_offset)
	elif spawn_left:
		spawn_x = randi_range(left_spawn_limit + enemy_offset, left_viewport - enemy_offset)
	elif spawn_right:
		spawn_x = randi_range(right_spawn_limit - enemy_offset, right_viewport + enemy_offset)
	else:
		spawn_x = 0 # FIX THE LITTLE SHIT
	
	if top_viewport > top_spawn_limit:
		spawn_top = true
		
	else:
		spawn_bot = true
		
	
	if spawn_top && spawn_bot:
		if randi_range(0, 1):
			spawn_y = randi_range(top_spawn_limit + enemy_offset, top_viewport - enemy_offset)
		else:
			spawn_y = randi_range(bottom_spawn_limit - enemy_offset, bottom_viewport + enemy_offset)
	elif spawn_top:
		spawn_y = randi_range(top_spawn_limit + enemy_offset, top_viewport - enemy_offset)
	elif spawn_bot:
		spawn_y = randi_range(bottom_spawn_limit - enemy_offset, bottom_viewport + enemy_offset)
	else:
		spawn_y = 0
	
	
	spawn_position = Vector2(spawn_x, spawn_y)
	
	return spawn_position
