extends Spatial

var tileTypes = {} #Types of tiles (Grass, Mountain, Water, etc)
var tiles = [] #2D array that contains integer representaions of the map
var graph = [] #2D array to contain graph of nodes

#var sorter = OrderByDist.new()
var mapSizeX = 10
var mapSizeY = 10

var selectedUnit #Unit that is moving around

var i = 0

#Can't call this "Node," Godot already has these
class Nodule:
	var x
	var y
	var neighbours = []
	func DistanceTo(node):
		return Vector2(x,y).distance_to(Vector2(node.x,node.y))

#Custom sorter
class OrderByDist:
	var dist = null
	func SetDict(d):
		dist = d
	func sort(a, b):
		return dist[a] < dist[b]

func _ready():
	#Grab reference to unit
	selectedUnit = self.get_node("Unit")
	#Initialize map tiles
	CreateMap()
	CreatePrefabs()
	GeneratePathfindingGraph()
	GenerateMapVisuals()

func _process(delta):
	print(i)
	i += 1

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
	selectedUnit.tileX = 0
	selectedUnit.tileY = 0

func GeneratePathfindingGraph():
	#initialize graph
	for x in range(mapSizeX):
		graph.append([])
		graph[x].resize(mapSizeY)
		for y in range(mapSizeY):
			var n = Nodule.new()
			n.x = x
			n.y = y
			graph[x][y] = n
	#set neighbors (Cannot be done in prev step as not all neighbors have been instanced)
	for x in range(mapSizeX):
		for y in range(mapSizeY):
			if x > 0 : graph[x][y].neighbours.append(graph[x-1][y])
			if x < mapSizeX - 1  : graph[x][y].neighbours.append(graph[x+1][y])
			if y > 0 : graph[x][y].neighbours.append(graph[x][y-1])
			if y < mapSizeY - 1  : graph[x][y].neighbours.append(graph[x][y+1])

func GenerateMapVisuals():
	for x in range(mapSizeX):
		for y in range(mapSizeY):
			#Grab tile type from dict
			var tt = tiles[x][y] 
			#instantiate
			var obj = tileTypes[tt].instance() 
			# add as child to keep reference to object
			self.add_child(obj) 
			#set tile's x and y coordinates independant of offset
			obj.TileX = x
			obj.TileY = y
			obj.map = self
			#Move tile to correct spot in game world
			obj.translate(Vector3(x, y, 0)*2) #Cube meshes are 2x2x2 by defualt

func TileCoordToWorldCoord(x,y):
	return Vector3(x,y,0)*2

func MoveSelectedUnitTo(x,y):
	#selectedUnit.translation = TileCoordToWorldCoord(x,y)
	#distance to a node
	var dist = {}
	#which node was the previous node of key node
	var prev = {}
	#List of unvisited nodes
	var unvisited = []
	#Start node
	var source = graph[selectedUnit.tileX][selectedUnit.tileY]
	var target = graph[x][y]
	#sorter.SetDict(dist)
	dist[source] = 0
	prev[source] = null
	#init everything to inf distance so they're not picked over an actual path.
	for i in graph:
		for j in i:
			if !(j == source):
				dist[j] = INF
				prev[j] = null
			unvisited.append(j)
	
	#While our queue still has nodes in it
	while !unvisited.empty():
		#unvisited.sort_custom(self, "sort")
		var u = null
		
		for i in unvisited:
			if u == null or dist[i] < dist[u]:
				u = i
		
		if u == target:
			break

		for vertex in u.neighbours:
			var alt = dist[u] + u.DistanceTo(vertex)
			if alt < dist[vertex]:
				dist[vertex] = alt
				prev[vertex] = u

func CreatePrefabs():
	#Load prefab scenes
	var grass = load("res://Grass.tscn")
	var mountain = load("res://Mountain.tscn")
	var swamp = load("res://Swamp.tscn")
	#add prefab scenes to dict
	tileTypes[0] = grass
	tileTypes[1] = swamp
	tileTypes[2] = mountain