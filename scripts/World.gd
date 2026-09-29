extends Node2D
class_name World

@onready var ground: TileMapLayer = $Ground

func _ready() -> void:
    add_to_group("world")
    _generate_tiles()

func _generate_tiles() -> void:
    if ground == null: return
    for x in range(-20, 21):
        for y in range(-20, 21):
            var t := 0
            if abs(x) < 3 and abs(y) < 3: t = 1
            ground.set_cell(Vector2i(x, y), 0, Vector2i(t, 0))
