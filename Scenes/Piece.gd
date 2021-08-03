extends Area2D

signal start_game
signal game_over
signal moved
signal captured(score)

var random = RandomNumberGenerator.new()
var deck = "KQBNRPkqbnrp"
export var id = ""
export var column = -1
export var row = -1
export var destination = Vector2()
export var speed = 512.0
export var move_delay = 1.0 / 7.0
export var move_delay_left = 0.0
export var fall_delay = 1.0
export var fall_delay_left = 1.0

func drop():
	
	var parent = get_parent()
	var r = row + 1
		
	while parent.is_square_open(column, r):
		
		r += 1
		
	r -= 1
	place(column, r)
	land()

var ranges = {
	'k' : 
	[[1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1], [1, 0]],
	'Q' :
	[[1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1], [1, 0]],
	'B' :
	[[1, 1], [-1, 1], [-1, -1], [1, -1]],
	'n' : 
	[[2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-1, -2], [1, -2], [2, -1]],
	'R' :
	[[0, 1], [-1, 0], [0, -1], [1, 0]],
	'P' :
	[[-1, -1], [1, -1]],
	'p' :
	[[-1, 1], [1, 1]]
}

var values = {
	'p' : 1,
	'n' : 3,
	'b' : 3,
	'r' : 5,
	'q' : 9,
	'k' : 10
}

func add_square(square, out, capture):
	
	var parent = get_parent()
	var on = parent.on_square(square[0], square[1])
	
	if on:
		
		var on_side = on.id.to_lower() == on.id
		var side = id.to_lower() == id
		
		if on_side != side:
	
			out.append(square)
			
	elif parent.is_square_open(square[0], square[1]):
		
		if not capture:
			
			out.append(square)
			
		return true
		
	return false

func get_long_range(capture):
	
	var ret = Array()
	var base = ranges[id.to_upper()]
	
	for v in base:
		
		var c = column
		var r = row
		
		while true:
			
			c += v[0]
			r += v[1]
		
			if not add_square([c, r], ret, capture):
				
				break
				
	return ret

func get_short_range(capture):
	
	var base = Array()
	var ret = Array()

	if id.to_upper() in ranges:
		
		base = ranges[id]
		
	else:
		
		base = ranges[id.to_lower()]

	for v in base:
		
		var square = [column + v[0], row + v[1]]
		add_square(square, ret, capture)
		
	return ret

func get_range(capture):
	
	var parent = get_parent()
	
	if id.to_lower() in ranges:
		
		return get_short_range(capture)

	elif id.to_upper() in ranges:
		
		return get_long_range(capture)

func capture():
	
	var parent = get_parent()
	var targets = get_range(true)
	var score = 0
	var count = 0
	
	for target in targets:
		
		var square = parent.get_square(target[0], target[1])
		var ID :String= square.capture()
		score += values[ID.to_lower()]
		count += 1
	
	score *= count
	emit_signal("captured", score)

func be_captured():
	
	var parent = get_parent()
	var ID = id.to_lower()
	
	if ID != "k":
	
		if ID == id:
			
			parent.black_count -= 1
			parent.black_captured = true
			
		else:
			
			parent.white_count -= 1
			parent.white_captured = true
	
	$AnimatedSprite.play("explode")
	$AnimatedSprite.connect("animation_finished", self, "_capture_animation_finished")
	$CollisionShape2D.queue_free()
	
	if id.to_lower() == "k":
		
		game_over()
	
	return id

func _capture_animation_finished():
	
	var parent = get_parent()
	
	if $AnimatedSprite.animation == "explode":
		
		if parent.game_on:
			
			queue_free()
			
		else:
			
			$AnimatedSprite.play(id)
			yield(get_tree().create_timer(0.5), "timeout")
			$AnimatedSprite.play("explode")

func snap():
	
	var parent = get_parent()
	destination = parent.square_position(column, row)
	position = destination

func update_speed():
	
	var main = get_tree().get_root().find_node("Main", true, false)
	fall_delay = main.speed()
	print(fall_delay)

func land():
	
	if not is_processing():
	
		return
		
	snap()
	capture()
	set_process(false)
	update_speed()
	
	yield(get_tree().create_timer(fall_delay), "timeout")
	
	var parent = get_parent()
	var ID = id.to_lower()
	
	if ID != "k":
	
		if ID == id:
			
			parent.black_count += 1
			
		else:
			
			parent.white_count += 1

	parent.shall_draft = true

func descend():
	
	if move(column, row + 1) and is_processing():

		emit_signal("moved")

	else:
		
		land()

func game_over():
	
	var parent = get_parent()
	var collision = get_node("CollisionShape2D")
	collision.set_disabled(true)
	
	set_process(false)
	emit_signal("game_over")
	parent.game_over()
	destination = parent.square_position(column, row)
	position = destination	

func enter_board():
	
	var parent = get_parent()
	
	if place(column, row):
		
		parent.white_captured = false
		parent.black_captured = false	
		
	else:

		game_over()

func move(c, r):
	
	var parent = get_parent()
	
	if not parent.is_square_open(c, r):
		
		return false

	destination = parent.square_position(c, r)
	column = c
	row = r
	return true

func place(c, r):
	
	if move(c, r):
		
		position = destination
		return true
		
	return false

func init(ID, c, r):
	
	id = ID
	var sprite = $AnimatedSprite
	sprite.init(id)	
	column = c
	row = r

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var Main = get_tree().get_root().find_node("Main",true,false)
	self.connect("start_game", Main, "_on_Piece_start_game")
	self.connect("moved", Main, "_on_Piece_moved")
	self.connect("captured", Main, "_on_Piece_captured")
	self.connect("game_over", Main, "_on_Piece_game_over")
	emit_signal("start_game")
	
	var parent = get_parent()
	if parent.name.find("Board") >= 0:
		
		enter_board()
			
	else:
		
		print("ERROR: parent must be Board, is " + parent.name)
		assert(false)

func delay_move():
	
	move_delay_left = move_delay

func process_travel(delta):
	
	var parent = get_parent()
	var tree = get_tree()
	
	if position != destination:

		var length = parent.cell_size.x
		var v = destination - position
		if v.y:
			length = parent.cell_size.y
		var ratio = v.length() / length

		var n = v.normalized()
		var inc = n * delta * speed * ratio
		position += inc

func process_descent(delta):
	
	if fall_delay_left:
		
		fall_delay_left -= delta
		fall_delay_left = max(fall_delay_left, 0.0)
		
	else:
		
		descend()
		fall_delay_left = fall_delay

func process_input(delta):
	
	if move_delay_left:
		
		move_delay_left -= delta
		move_delay_left = max(move_delay_left, 0.0)
		
	else:
		
		if Input.is_action_pressed("input_left"):
			
			delay_move()
			move(column - 1, row)
			
		if Input.is_action_pressed("input_right"):
			
			delay_move()
			move(column + 1, row)

		if Input.is_action_pressed("input_fall"):
			
			delay_move()
			
			if not move(column, row + 1):
				
				land()
		
		if Input.is_action_just_pressed("input_drop"):
			
			drop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var parent = get_parent()
	
	if parent.game_on:
		
		pass
		
	else:
		
		return
	
	process_travel(delta)
	process_descent(delta)
	process_input(delta)
