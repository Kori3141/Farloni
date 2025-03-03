extends Node

var astar_grid: AStarGrid2D

@onready var home_pos = {
	'halla': Vector2.ZERO,
	'fresa': Vector2.ZERO,
	'serfa': Vector2.ZERO
}

var char_array = []

@onready var char = "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	astar_grid = AStarGrid2D.new()

func _process(delta: float) -> void:
	if len(char_array) == 3:
		char_array.clear()
