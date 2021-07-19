extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func capture():
	
	var on = get_overlapping_areas()
	assert(len(on) <= 1)
	
	if on:
		
		return on[0].be_captured()
		
	return 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	var child = get_child(0)
	child.shape = RectangleShape2D.new()
	child.shape.set_extents(parent.cell_size * 0.1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
