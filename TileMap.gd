extends Spatial

var tileTypes = {} #Types of tiles (Grass, Mountain, Water, etc)
var tiles = [] #2D array that contains integer representaions of the map

var mapSizeX = 10
var mapSizeY = 10

func _ready():
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
	for y in range(mapSizeY):
		for x in range(mapSizeX):
			var tt = tiles[y][x] #Grab 
			print(tileTypes[tt])
			var obj = tileTypes[tt].instance()
			self.add_child(obj) 
			obj.translate(Vector3(y, x, 0)*2) #Cube meshes are 2x2x2 by defualt

func CreatePrefabs():
	var grass = load("res://Grass.tscn")
	var mountain = load("res://Mountain.tscn")
	var swamp = load("res://Swamp.tscn")
	tileTypes[0] = grass
	tileTypes[1] = swamp
	tileTypes[2] = mountain