extends Area2D

signal start_game
signal game_over
signal moved
signal captured(score)

var random = RandomNumberGenerator.new()
var deck = "KQBNRPkqbnrp"
var demo :bool= false
var drop_down :bool= false
export var id = ""
export var column = -1
export var row = -1
export var destination = Vector2()
export var speed = 512.0
export var move_delay = 1.0 / 7.0
export var move_delay_left = 0.0
export var fall_delay = 1.0
export var fall_delay_left = 1.0

var LEFT := "input_left"
var RIGHT := "input_right"
var FALL := "input_fall"
var DROP := "input_drop" 

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
	return score

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

func promote():
	
	if id.to_lower() != 'p':
		
		return
		
	var from := "RnBqQbNr"
	var to := from[column]
	
	if id == id.to_upper():
		
		if not row:
			
			id = to.to_upper()
			
	elif row == 7:
		
		id = to.to_lower()
			
	$AnimatedSprite.init(id)

func land():
	
	var parent = get_parent()
		
	snap()
	promote()
	var score = capture()
	set_process(false)
	
	parent.landed(id, score)

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
	parent.game_over()
	destination = parent.square_position(column, row)
	position = destination	
	
	$AnimatedSprite.play("explode")

func enter_board():
	
	var main = get_tree().get_root().get_node("Main")
	
	assert(main)
	
	if main.state == main.State.DEMO:
		
		print("in demo")
		demo = true
		LEFT = "demo_left"
		RIGHT = "demo_right"
		FALL = "demo_fall"
		DROP = "demo_drop"
	
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
	self.connect("moved", Main, "_on_Piece_moved")
	
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
		
		if false:
		
			if Input.is_action_pressed(LEFT):
				
				print("Piece: LEFT action failed")
			
			if Input.is_action_pressed(RIGHT):
				
				print("Piece: RIGHT action failed")
			
			if Input.is_action_pressed(FALL):
				
				print("Piece: FALL action failed")
				
			if Input.is_action_pressed(DROP):
				
				print("Piece: DROP action failed")
				
		move_delay_left -= delta
		move_delay_left = max(move_delay_left, 0.0)
		
	else:
		
		if Input.is_action_pressed(LEFT):
			
			delay_move()
			move(column - 1, row)
			
		if Input.is_action_pressed(RIGHT):
			
			delay_move()
			move(column + 1, row)

		if Input.is_action_pressed(FALL):
			
			delay_move()
			
			if not move(column, row + 1):
				
				land()
		
		if Input.is_action_pressed(DROP) and not drop_down:
			
			drop()
			drop_down = true
			
		else:
			
			drop_down = false

func crash():
	
	$AnimatedSprite.play("explode")

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
