extends Node

var TileX
var TileY
var map

#Make sure to set input to pickable in Area, or mouse signals will not be sent
#also ensure all areas and collisionshapes are made correctly, including signals
func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if Input.is_action_just_released("Left_Click"):
		map.GeneratePathTo(TileX,TileY)