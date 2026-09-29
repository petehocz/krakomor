extends Node2D
class_name World

@onready var ground: TileMapLayer = $Ground

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    add_to_group("world")
    rng.seed = 1337
    _generate_tiles()
    if not multiplayer.has_multiplayer_peer() or multiplayer.is_server():
        _spawn_resources()
        _spawn_npcs()
        _spawn_stations()

func _generate_tiles() -> void:
    if ground == null: return
    for x in range(-30, 31):
        for y in range(-30, 31):
            var t := 0
            if abs(x) < 3 and abs(y) < 3: t = 1
            ground.set_cell(Vector2i(x, y), 0, Vector2i(t, 0))

func _spawn_resources() -> void:
    var scene: PackedScene = load("res://scenes/ResourceNode.tscn")
    if scene == null: return
    for i in range(30):
        var n = scene.instantiate()
        n.resource_type = ["iron_ore", "coal_ore", "oak_log", "herb_common"][rng.randi() % 4]
        n.global_position = Vector2(rng.randf_range(-500, 500), rng.randf_range(-500, 500))
        add_child(n)

func _spawn_npcs() -> void:
    for i in range(15):
        NPCDatabase.spawn(self, "rabbit", Vector2(rng.randf_range(-500, 500), rng.randf_range(-500, 500)))
    for i in range(8):
        NPCDatabase.spawn(self, "wolf", Vector2(rng.randf_range(-500, 500), rng.randf_range(-500, 500)))
    for i in range(3):
        NPCDatabase.spawn(self, "bear", Vector2(rng.randf_range(-500, 500), rng.randf_range(-500, 500)))
    NPCDatabase.spawn(self, "bandit", Vector2(rng.randf_range(-500, 500), rng.randf_range(-500, 500)))

func _spawn_stations() -> void:
    var scene: PackedScene = load("res://scenes/CraftingStation.tscn")
    if scene == null: return
    var types := ["anvil", "furnace", "workbench", "loom", "cauldron", "hearth"]
    for i in range(types.size()):
        var s = scene.instantiate()
        s.station_type = types[i]
        var a := TAU * i / types.size()
        s.global_position = Vector2(cos(a), sin(a)) * 200.0
        add_child(s)
