extends Spatial

var tileTypes = {} #Types of tiles (Grass, Mountain, Water, etc)
var tiles = [] #2D array that contains integer representaions of the map
var graph = [] #2D array to contain graph of nodes
var currentPath = [] #Array that becomes path

onready var nodule = load("res://nodule.gd")
onready var ttype = load("res://TileType.gd")

var mapSizeX = 10
var mapSizeY = 10

var selectedUnit #Unit that is moving around

func _ready():
	#Grab reference to unit
	selectedUnit = self.get_node("Unit")
	selectedUnit.map = self
	selectedUnit.UpdatePos(0,0)
	#Initialize map tiles
	CreateMap()
	CreatePrefabs()
	GeneratePathfindingGraph()
	GenerateMapVisuals()

#Creates 2D array
func CreateMap():
	for x in range(mapSizeX):
        tiles.append([])
        tiles[x].resize(mapSizeY)
        for y in range(mapSizeY):
            tiles[x][y] = 0 #Default value
	#generate swamp
	for x in range(3,6):
		for y in range(0,4):
			tiles[x][y] = 1
	#Generate mountain range
	tiles[4][4] = 2
	tiles[5][4] = 2
	tiles[6][4] = 2
	tiles[7][4] = 2
	tiles[8][4] = 2
	tiles[8][5] = 2
	tiles[8][6] = 2
	tiles[4][5] = 2
	tiles[4][6] = 2

#generates node graph to follow
func GeneratePathfindingGraph():
	#initialize graph
	for x in range(mapSizeX):
		graph.append([])
		graph[x].resize(mapSizeY)
		for y in range(mapSizeY):
			var n = nodule.new()
			n.x = x
			n.y = y
			graph[x][y] = n
	#set neighbors (Cannot be done in prev step as not all neighbors have been instanced)
	for x in range(mapSizeX):
		for y in range(mapSizeY):
			#Four direction version
			"""
			if x > 0: graph[x][y].neighbours.append(graph[x-1][y])
			if x < mapSizeX - 1: graph[x][y].neighbours.append(graph[x+1][y])
			if y > 0: graph[x][y].neighbours.append(graph[x][y-1])
			if y < mapSizeY - 1: graph[x][y].neighbours.append(graph[x][y+1])
			"""
			#8 Direction version
			if x > 0: 
				graph[x][y].neighbours.append(graph[x-1][y])
				if y > 0: graph[x][y].neighbours.append(graph[x-1][y-1])
				if y < mapSizeY - 1: graph[x][y].neighbours.append(graph[x-1][y+1])
			if x < mapSizeX - 1:
				graph[x][y].neighbours.append(graph[x+1][y])
				if y > 0: graph[x][y].neighbours.append(graph[x+1][y-1])
				if y < mapSizeY - 1: graph[x][y].neighbours.append(graph[x+1][y+1])
			if y > 0: graph[x][y].neighbours.append(graph[x][y-1])
			if y < mapSizeY - 1: graph[x][y].neighbours.append(graph[x][y+1])

func UnitCanEnterTile(x,y):
	return tileTypes[tiles[x][y]].isWalkable

#Draws the objects in space
func GenerateMapVisuals():
	for x in range(mapSizeX):
		for y in range(mapSizeY):
			#Grab tile type from dict
			var tt = tiles[x][y] 
			#instantiate
			var obj = tileTypes[tt].prefab.instance() 
			# add as child to keep reference to object
			self.add_child(obj) 
			#set tile's x and y coordinates independant of offset
			obj.TileX = x
			obj.TileY = y
			obj.map = self
			#Move tile to correct spot in game world
			obj.translate(Vector3(x, y, 0)*2) #Cube meshes are 2x2x2 by defualt

#Converts tile x and y to worldspace x and y
func TileCoordToWorldCoord(x,y):
	return Vector3(x,y,0)*2

#Returns the cost of entering a tile 
func CostToEnterTile(sourceX,sourceY,targetX,targetY):
	if !UnitCanEnterTile(targetX,targetY):
		return INF
	var cost = tileTypes[tiles[targetX][targetY]].movementCost
	if sourceX != targetX and sourceY != targetY:
		cost += 0.001
	return cost

#returns a list of nodes in order to provide a path
func GeneratePathTo(x,y):
	currentPath.clear()
	#distance to a node
	var dist = {}
	#which node was the previous node of key node
	var prev = {}
	#List of unvisited nodes
	var unvisited = []
	#Start node
	var source = graph[selectedUnit.tileX][selectedUnit.tileY]
	var target = graph[x][y]
	dist[source] = 0
	prev[source] = null
	#init everything to inf distance so they're not picked over an actual path.
	#Need two for loops to cover secondary arrays
	for i in graph:
		for j in i:
			if !(j == source):
				dist[j] = INF
				prev[j] = null
			unvisited.append(j)
	
	#While our queue still has nodes in it
	while !unvisited.empty():
		var u = null
		for i in unvisited:
			if u == null or dist[i] < dist[u]:
				u = i
		if u == target:
			break
		unvisited.erase(u)
		for vertex in u.neighbours:
			#var alt = dist[u] + u.DistanceTo(vertex)
			var alt = dist[u] + CostToEnterTile(u.x,u.y,vertex.x,vertex.y)
			if alt < dist[vertex]:
				dist[vertex] = alt
				prev[vertex] = u
	
	#Either we've found our target or there is no route
	if prev[target] == null:
		#no route to target
		return
	#Generate path
	var curr = target;
	while curr != null:
		currentPath.append(curr)
		curr = prev[curr]
	#reverse path to get correct sequence
	currentPath.invert()
	selectedUnit.currentPath = currentPath
	selectedUnit.DrawPath()

#generates the prefabs 
func CreatePrefabs():
	#Load prefab scenes
	tileTypes[0] = ttype.new("grass",load("res://Grass.tscn"),1,true)
	tileTypes[1] = ttype.new("swamp",load("res://Swamp.tscn"),2,true)
	tileTypes[2] = ttype.new("mountain",load("res://Mountain.tscn"),INF,true)