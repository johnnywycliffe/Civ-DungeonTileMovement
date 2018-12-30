extends Node
#Can't call this "Node," Godot already has these
var x
var y
var neighbours = []
func DistanceTo(node):
	return Vector2(x,y).distance_to(Vector2(node.x,node.y))