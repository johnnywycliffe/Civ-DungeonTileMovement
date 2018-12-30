extends Node
 
var prefab
var movementCost
var isWalkable

func _init(n,tt,movecost,walk):
	self.name = n
	self.prefab = tt
	self.movementCost = movecost
	self.isWalkable = walk