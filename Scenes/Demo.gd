extends Node

signal done

export var sequence : PoolStringArray
var sequence_index = 0

export var record_filename :String= "res://Demos/record.demo"
var replay_filename :String= ""
var record :bool= false
var replay :bool= false
var demo_prefix :String= "demo_"
var input_prefix :String= "input_"

var record_file :File= File.new()
var replay_file :File= File.new()

var replay_line :String= ""
var replay_glyph_0 :String= ""
var replay_time :float= 0.0
var replay_glyph_1 :String= ''
var replay_action :String= ""

var GLYPH_0_AT := '@'
var GLYPH_0_AFTER := '+'
var GLYPH_1_PRESS := '<'
var GLYPH_1_RELEASE := '>'

var actions := ['left', "right", "fall", "drop"]

var last_time = -1.0
var time = -1.0

func play_sequence(next):

	stop_replaying()
	
	if not next:
		
		sequence_index = 0
		
	if sequence_index >= len(sequence) or sequence_index < 0:
		
		emit_signal("done")
		sequence_index = 0
		return false
		
	replay_filename = sequence[sequence_index]
	start_replaying()
	return true
	
func play_next(direction = 1):
	
	var parent = get_parent()
	sequence_index += direction
	parent.next_demo()

func start_replaying()->void:
	
	assert(replay_file.file_exists(replay_filename))	
	
	print("Demo.start_replaying()")	
	
	replay_file.open(replay_filename, File.READ)
	replay = true
	time = 0.0
	last_time = 0.0
	set_process(true)

func stop_replaying()->void:
	
	print("Demo.stop_replaying()")	
	replay_filename = ""
	replay = false
	time = -1.0
	last_time = -1.0
	
	if replay_file.is_open():
		
		replay_file.close()

	set_process(false)

func start_recording()->void:
	
	assert(File.new().file_exists(record_filename))
	print("Demo.start_recording()")
	stop_recording()
	stop_replaying()
	
	record = true
	record_file.open(record_filename, File.WRITE)
	time = 0.0
	last_time = 0.0
	set_process(true)

func stop_recording()->void:
	
	record = false
	time = -1.0
	last_time = -1.0
	
	if record_file.is_open():
		
		record_file.close()
		
	set_process(false)

# Called when the node enters the scene tree for the first time.
func _ready():

	set_process(false)

func record_line(status, action):
	
	var timestamp = str(time)
	var line = GLYPH_0_AT + ' ' + timestamp + ' ' + status + ' ' + action
	record_file.store_line(line)
	print("recorded: " + line + " to: " + record_filename)

func record_process(delta)->void:

	assert(record_file.is_open())
	
	for action in actions:
		
		var input_action = input_prefix + action
		
		if Input.is_action_just_pressed(input_action):
			
			record_line(GLYPH_1_PRESS, action)
			
		if Input.is_action_just_released(input_action):
			
			record_line(GLYPH_1_RELEASE, action)

func done():
	
	stop_recording()
	stop_replaying()
	
	emit_signal("done")
	
func replay_process(delta)->void:
	
	assert(replay_file.is_open())
	
	if not replay_line:

		if replay_file.eof_reached():
			
			play_next()
			return

		replay_line = replay_file.get_line()
		
		if len(replay_line) <= 1:
			
			play_next()
			return
		
		var parts := replay_line.split(' ')
		
		replay_glyph_0 = parts[0]	
		replay_time = float(parts[1])
		replay_glyph_1 = parts[2]
		replay_action = parts[3]
	
		for i in range(4, len(parts)):
			
			replay_action += ' ' + parts[i]
	
	var now = false
	
	match replay_glyph_0:
		
		GLYPH_0_AT:
			
			now = time >= replay_time
			last_time = replay_time
			
		GLYPH_0_AFTER:
			
			now = time >= last_time + replay_time
			
		_:
			
			assert(false)
				
	if now:
		
		var demo_action :String= demo_prefix + replay_action
		
		match replay_glyph_1:
			
			GLYPH_1_PRESS:
			
				print("Demo: pressed " + demo_action)
				Input.action_press(demo_action)
			
			GLYPH_1_RELEASE:
				
				print("Demo: released " + demo_action)
				Input.action_release(demo_action)
			
			_:
				
				assert(replay_glyph_1.is_valid_integer())
				
				var where = int(replay_glyph_1)
				
				assert(where >= 0 and where <= 5)
				
				get_parent().say(where, replay_action)

		replay_line = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if record or replay:
		
		time += delta
	
	if record:
		
		record_process(delta)
		
	if replay:
		
		replay_process(delta)
		
	if Input.is_action_just_pressed("input_left"):
		
		play_next(-1)
		
	elif Input.is_action_just_pressed("input_right"):
		
		play_next(1)
		
func _exit_tree():
	
	stop_recording()
	stop_replaying()
