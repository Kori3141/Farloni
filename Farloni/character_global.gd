@icon("res://sprites/Halla_Placeholder.png")
class_name character extends Area2D

@onready var tilemap = $"../../Tilemaps/TileMapLayer"
@onready var tilemapover = $"../../Tilemaps/OverlayTiles"
@export var move_range = 5
@export var char_name = "None"
var current_id_path: Array[Vector2i]
var target_pos: Vector2
var is_moving: bool
var deactive: bool
var should_end_turn = false

func _ready():
	Global.astar_grid.region = tilemap.get_used_rect()
	Global.astar_grid.cell_size = Vector2(16, 16)
	Global.astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	Global.astar_grid.update()
	get_node("/root/Global").home_pos[char_name] = tilemap.local_to_map(global_position)

func _input(event): #Checks For Input
	if event.is_action_pressed("end_turn"):
		end_turn_check()
		return

	if event.is_action_pressed("move") == true && Global.char != char_name && Global.char_array.find(char_name) == -1:
		if tilemap.local_to_map(global_position) == tilemap.local_to_map(get_global_mouse_position()):
			map_move_squares()
			Global.char = char_name
			deactive = true

	elif event.is_action_pressed("move") == false:
		return

	elif Global.char == char_name:
		var id_path
		if len(Global.astar_grid.get_id_path(get_node("/root/Global").home_pos[char_name],tilemap.local_to_map(get_global_mouse_position()))) > move_range + 1:
			return
		if is_moving:
			id_path = Global.astar_grid.get_id_path(
				tilemap.local_to_map(target_pos),
				tilemap.local_to_map(get_global_mouse_position())
			).slice(1)
		else:
			id_path = Global.astar_grid.get_id_path(
				tilemap.local_to_map(global_position),
				tilemap.local_to_map(get_global_mouse_position())
			).slice(1)
		
		if id_path.is_empty() == false:
			current_id_path = id_path

func _physics_process(delta): #All Movement happens here
	if char_name == Global.char:
		map_move_squares()
	elif char_name != Global.char && deactive == true:
		unmap_move_squares()
		deactive = false

	if current_id_path.is_empty():
		return

	if is_moving == false:
		target_pos = tilemap.map_to_local(current_id_path.front())
		is_moving = true
	global_position = global_position.move_toward(target_pos, 1)
	if global_position == target_pos:
		current_id_path.pop_front()
		
		if current_id_path.is_empty() == false:
			target_pos = tilemap.map_to_local(current_id_path.front())
		else:
			is_moving = false

func map_move_squares(): #Sets up a map based on the character’s movement
	var source = get_node("/root/Global").home_pos[char_name]
	var move = []
	for x in range(move_range + 1):
		for y in range(move_range + 1):
			if x + y <= move_range:
				move.append([source.x+x,source.y+y])
				move.append([source.x-x,source.y+y])
				move.append([source.x-x,source.y-y])
				move.append([source.x+x,source.y-y])
	for cells in move:
		tilemapover.set_cell(Vector2(cells[0],cells[1]),0, Vector2i(0,0))
	return
	
func unmap_move_squares(): #Unmaps area up a map based on the character’s movement
	var source = get_node("/root/Global").home_pos[char_name]
	var move = []
	for x in range(move_range + 1):
		for y in range(move_range + 1):
			if x + y <= move_range:
				move.append([source.x+x,source.y+y])
				move.append([source.x-x,source.y+y])
				move.append([source.x-x,source.y-y])
				move.append([source.x+x,source.y-y])
	for cells in move:
		tilemapover.set_cell(Vector2(cells[0],cells[1]),0, Vector2i(1,0))
	return

func end_turn_check(): #Runs an End Turn Process
	if should_end_turn:
		unmap_move_squares()
		get_node("/root/Global").home_pos[char_name] = tilemap.local_to_map(global_position)
		should_end_turn = false
		Global.char = "none"
		Global.char_array.append(char_name)
		return true
	elif  Global.char == char_name:
		should_end_turn = true
		return true
	return false
