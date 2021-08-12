extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Piece = load("res://Scenes/Piece.tscn")
var Square = load("res://Scenes/Square.tscn")
var GameOver = load("res://Scenes/GameOver.tscn")
var game_on := false
var white_captured := false
var black_captured := false
var draft_delay := INF
export var ROWS := 8
export var COLS := 8
onready var WIDTH := COLS * cell_size.x
onready var HEIGHT := ROWS * cell_size.y
onready var BASE_CHILDREN := get_child_count()
onready var draft_count := 0
onready var white_count := 0
onready var black_count := 0

signal game_over
signal landed(id, score)

func first_child_index_after_squares():
	
	return ROWS * COLS + BASE_CHILDREN

func clear():
	
	_init()
	
	for child in range(first_child_index_after_squares(), get_child_count()):
		
		get_children()[child].queue_free()

func landed(id, score):
	
	var ID = id.to_lower()
	
	if ID != "k":
	
		if ID == id:
			
			black_count += 1
			
		else:
			
			white_count += 1
	
	print("Board.landed()")
	emit_signal("landed", id, score)

func queue_draft(id, delay):
			
	draft_delay = delay

func get_square(c, r):
	
	var index = c * ROWS + r + BASE_CHILDREN
	
	if index < 0 or index >= first_child_index_after_squares():
		
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
	
	var ret = not black_count and black_captured
	return ret or not white_count and white_captured

func draft(id, column):
	
	var on = on_square(column, 0)

	if on:
		
		on.game_over()
	
	else:
	
		var player = Piece.instance()
		player.init(id, column, 0)
		self.add_child(player)
		draft_count += 1

func game_over():
	
	emit_signal("game_over")

func end_game():
	
	game_on = false

func play():
	
	game_on = true
		
	for child in get_children():
	
		if child.name.find("Piece") >= 0:
			
			child.visible = true

func _init():
	
	draft_delay = INF
	draft_count = 0
	game_on = false
	white_captured = false
	black_captured = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for c in range(COLS):
		
		for r in range(ROWS):
			
			var square = Square.instance()
			square.position.x = c * cell_size.x - WIDTH * 0.5
			square.position.y = r * cell_size.y - HEIGHT * 0.5
			square.position += cell_size * 0.5
			self.add_child(square)

func _exit_tree():
	print("board exit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if draft_delay == INF:
		
		pass
	
	elif draft_delay <= 0.0 and game_on:
		
		draft_delay = INF
		#draft()
		
	else:
		
		draft_delay -= delta

func pause():
	
	game_on = false
	for child in get_children():
		
		if child.name.find("Piece") >= 0:
			
			child.visible = false
