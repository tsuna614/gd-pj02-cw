extends Camera2D

@onready var tilemap: TileMapLayer = $"../../Ground/TileMapLayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bounds = tilemap.get_used_rect()           # Rect2 in tile coords
	var tile_size = tilemap.tile_set.tile_size
	
	#print(tile_size)

	limit_left   = bounds.position.x * tile_size.x
	limit_top    = bounds.position.y * tile_size.y
	limit_right  = bounds.end.x * tile_size.x
	limit_bottom = bounds.end.y * tile_size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
