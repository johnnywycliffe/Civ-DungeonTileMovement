extends Spatial

var tileX
var tileY
var map
var currentPath = null
var unitBasis = Basis(Vector3(0.5,0,0),Vector3(0,0.5,0),Vector3(0,0,0.5))
var moveSpeed = 2

func UpdatePos(x,y):
	self.tileX = x/2
	self.tileY = y/2
	self.transform = Transform(unitBasis,Vector3(x,y,0))
	DrawPath()

func DrawPath():
	if currentPath == null: return
	var im = get_node("Draw")
	im.clear()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for i in currentPath:
		var j = Vector3(i.x*4-tileX*4,i.y*4-tileY*4,3)
		im.add_vertex(j)
	im.end()

func MoveToNextTile():
	var remainingMovement = moveSpeed
	while remainingMovement > 0:
		if currentPath == null: return
		var on = currentPath.pop_front()
		remainingMovement -= map.CostToEnterTile(on.x,on.y,currentPath.front().x,currentPath.front().y)
		var worldCoords = map.TileCoordToWorldCoord(currentPath.front().x,currentPath.front().y)
		self.UpdatePos(worldCoords.x,worldCoords.y)
		if currentPath.size() == 1:
			currentPath = null