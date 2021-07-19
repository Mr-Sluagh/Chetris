extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Piece = load("res://Scenes/Piece.tscn")
var Square = load("res://Scenes/Square.tscn")
var GameOver = load("res://Scenes/GameOver.tscn")
var game_on = false
var white_captured = false
var black_captured = false
export var ROWS = 8
export var COLS = 8
onready var WIDTH = COLS * cell_size.x
onready var HEIGHT = ROWS * cell_size.y
onready var BASE_CHILDREN = get_child_count()
onready var draft_count = 0
onready var white_count = 0
onready var black_count = 0

signal game_over

func get_square(c, r):
	
	var index = c * ROWS + r + BASE_CHILDREN
	
	if index < 0 or index >= ROWS * COLS + BASE_CHILDREN:
		
		return null
	
	return get_child(index)

func square_position(c, r):
	
	var ret = Vector2()
	var width = cell_size.x * COLS
	var height = cell_size.y * ROWS
	ret.x = c * cell_size.x - width * 0.5 + cell_size.x * 0.5
	ret.y = r * cell_size.y - height * 0.5 + cell_size.y * 0.5
	return ret

func on_square(c, r):
	
	if not self.has_square(c, r):
		
		return null
	
	var square = get_square(c, r)
	var on = square.get_overlapping_areas()
	
	if len(on):
		return on[0]
	return null

func has_square(c, r):

	return c >= 0 and r >= 0 and c < COLS and r < ROWS
	
func is_square_open(c, r):
		
	if not has_square(c, r):
		
		return false
		
	if on_square(c, r):
		
		return false
		
	return true

func is_king_exposed():
	
	return not black_count or not white_count

func draft():
	
	if not game_on:
		
		return
	
	var main = get_tree().get_root().find_node("Main", true, false)
	
	if not main:
		
		print("Board.draft(): Main scene not found")
		assert(false)
	
	var id = main.draft()
	var player = Piece.instance()
	player.init(id, main.cursor, 0)
	self.add_child(player)
	draft_count += 1

func game_over():
	
	game_on = false
	emit_signal("game_over")

func play():
	
	game_on = true
	
	if not draft_count:
		
		draft()
		
	for child in get_children():
	
		if child.name == "Piece":
			
			child.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print("board ready, name = " + name)
	assert(name == "Board")
	
	for c in range(COLS):
		
		for r in range(ROWS):
			
			var square = Square.instance()
			square.position.x = c * cell_size.x - WIDTH * 0.5
			square.position.y = r * cell_size.y - HEIGHT * 0.5
			square.position += cell_size * 0.5
			self.add_child(square)
	
	#play()

func _exit_tree():
	print("board exit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func pause():
	
	game_on = false
	for child in get_children():
		
		if child.name == "Piece":
			
			child.visible = false
