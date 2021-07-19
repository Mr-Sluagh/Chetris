extends Sprite
export var id := ""
export var key = Vector3.ZERO
export var good = Vector3(0.0,1.0,0.0)
export var bad = Vector3(1.0,0.0,0.0)
export var may = Vector3(1.0,1.0,0.0)
export var off = Vector3.ZERO

enum STATE {
	BAD = -1,
	OFF = 0,
	GOOD = 1,
	MAY = 2
}

var state = STATE.OFF

func on(value):

	material.set_shader_param("key", key)
	material.set_shader_param("val", value)

func good_on():
	
	state = STATE.GOOD
	on(good)

func bad_on():
	
	state = STATE.BAD
	on(bad)
	
func may_on():
	
	state = STATE.MAY
	on(may)
	
func off():
	
	state = STATE.OFF
	on(off)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	material = material.duplicate()
	off()
