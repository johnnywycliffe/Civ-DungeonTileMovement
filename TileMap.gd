extends Spatial

var tileTypes = {} #Types of tiles (Grass, Mountain, Water, etc)
var tiles = [] #2D array that contains integer representaions of the map

var mapSizeX = 10
var mapSizeY = 10

var selectedUnit

func _ready():
	#Grab reference to unit
	selectedUnit = self.get_node("Unit")
	#Initialize map tiles
	CreateMap()
	CreatePrefabs()
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
	selectedUnit.tileX = x
	selectedUnit.tileY = y
	selectedUnit.translation = TileCoordToWorldCoord(x,y)

func CreatePrefabs():
	#Load prefab scenes
	var grass = load("res://Grass.tscn")
	var mountain = load("res://Mountain.tscn")
	var swamp = load("res://Swamp.tscn")
	#add prefab scenes to dict
	tileTypes[0] = grass
	tileTypes[1] = swamp
	tileTypes[2] = mountain