extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


enum TimeFormat {
	FORMAT_HOURS = 1,
	FORMAT_MINUTES = 2,
	FORMAT_SECONDS = 4,
	FORMAT_DEFAULT = 7}

export var DIGITS = 8

func format_time(time, format = TimeFormat.FORMAT_DEFAULT, digit_format = "%02d"):
	
	var digits = []
	
	if format & TimeFormat.FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)

	if format & TimeFormat.FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)

	if format & TimeFormat.FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)

	var formatted = String()
	var colon = ":"

	for digit in digits:
		formatted += digit + colon

	if not formatted.empty():
		formatted = formatted.rstrip(colon)

	return formatted

func format_score(score):
	
	var ret = ""
	
	for digit in range(DIGITS):
		
		if score > 0:
			
			ret = str(score % 10) + ret
			score /= 10

		else:
		
			ret = "0" + ret
	
	return ret

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_content(name, readout):
	
	$Name.text = name
	$Readout.text = readout

func set_time(time):
	
	set_content("Time", format_time(time))
	
func set_score(score):
	
	set_content("Score", format_score(int(score)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
