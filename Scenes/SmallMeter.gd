extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var DIGITS = 3

func format_value(score):
	
	var ret = ""
	
	for digit in range(DIGITS):
		
		if score > 0:
			
			ret = str(score % 10) + ret
			score /= 10

		else:
		
			ret = "0" + ret
	
	assert(len(ret) <= DIGITS)
	
	return ret

func set_value(value):
	
	$Readout.text = format_value(int(value))

func init(name, value):
	
	$Name.text = name
	$Readout.text = format_value(int(value))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
