class_name NPCDatabase
extends RefCounted

const DB := {
    "rabbit": {"name": "Kralik", "hp": 5, "damage": 1, "speed": 60, "level": 0, "vision": 96, "aggro": 0},
    "deer": {"name": "Srna", "hp": 15, "damage": 2, "speed": 90, "level": 0, "vision": 128, "aggro": 0},
    "boar": {"name": "Kanec", "hp": 40, "damage": 5, "speed": 85, "level": 1, "vision": 160, "aggro": 1},
    "wolf": {"name": "Vlk", "hp": 35, "damage": 6, "speed": 120, "level": 2, "vision": 320, "aggro": 2},
    "bear": {"name": "Medved", "hp": 90, "damage": 12, "speed": 90, "level": 3, "vision": 256, "aggro": 1},
    "bandit": {"name": "Zbojnik", "hp": 60, "damage": 8, "speed": 95, "level": 3, "vision": 288, "aggro": 2},
    "skeleton": {"name": "Kostlivec", "hp": 50, "damage": 6, "speed": 80, "level": 2, "vision": 200, "aggro": 3},
    "skeleton_chief": {"name": "Kostlivy nacelnik", "hp": 200, "damage": 18, "speed": 90, "level": 5, "vision": 256, "aggro": 3},
    "troll": {"name": "Troll", "hp": 400, "damage": 25, "speed": 80, "level": 7, "vision": 320, "aggro": 3},
    "lich": {"name": "Lich", "hp": 1200, "damage": 60, "speed": 90, "level": 9, "vision": 480, "aggro": 3},
}

static func get_npc(id: String) -> Dictionary:
    return DB.get(id, {})

static func spawn(world: Node, npc_id: String, pos: Vector2, in_dungeon: bool = false) -> Node:
    var d := get_npc(npc_id)
    if d.is_empty(): return null
    var scene: PackedScene = load("res://scenes/NPC.tscn")
    if scene == null: return null
    var n = scene.instantiate()
    n.npc_id = npc_id
    n.npc_name = d["name"]
    n.max_hp = d["hp"]
    n.hp = d["hp"]
    n.damage = d["damage"]
    n.speed = d["speed"]
    n.level = d["level"]
    n.vision_range = d["vision"]
    n.aggro_type = d["aggro"]
    n.is_in_dungeon = in_dungeon
    n.global_position = pos
    world.add_child(n)
    return n
