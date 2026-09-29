class_name Items
extends RefCounted

const DB := {
    "iron_ore":    {"name": "Zelezna ruda",  "type": "ore", "tier": 1, "value": 3,  "stack": 100, "skill": "mining", "min_skill": 0},
    "silver_ore":  {"name": "Stribrna ruda", "type": "ore", "tier": 2, "value": 15, "stack": 100, "skill": "mining", "min_skill": 30},
    "coal_ore":    {"name": "Uhli",          "type": "ore", "tier": 0, "value": 2,  "stack": 100, "skill": "mining", "min_skill": 0},
    "oak_log":     {"name": "Dubovy kmen",   "type": "log", "tier": 1, "value": 3,  "stack": 50,  "skill": "carpentry", "min_skill": 0},
    "herb_common": {"name": "Kopriva",       "type": "herb","tier": 0, "value": 1,  "stack": 200, "skill": "herbalism", "min_skill": 0},
    "iron_ingot":  {"name": "Zelezny ingot", "type": "ingot","tier": 1, "value": 12, "stack": 50},
    "leather":     {"name": "Kuze",          "type": "mat",  "tier": 1, "value": 5,  "stack": 50},
    "cloth":       {"name": "Latka",         "type": "mat",  "tier": 1, "value": 6,  "stack": 50},
    "iron_sword":  {"name": "Zelezny mec",   "type": "weapon","tier": 1, "damage": 10, "value": 80, "stack": 1},
    "lockpick":    {"name": "Paklic",        "type": "key",  "tier": 1, "value": 5,  "stack": 100},
}

const ENCHANT_LEVELS := [0, 1, 3, 7, 9, 15, 19, 21, 25, 28, 30]
const ENCHANT_NAMES := {0: "", 1: "+1", 3: "+3", 7: "+7", 9: "+9", 15: "+15", 19: "+19", 21: "+21", 25: "+25", 28: "+28", 30: "+30"}

static func enchant_multiplier(level: int) -> float:
    return 1.0 + level * 0.10

static func parse_enchant(id: String) -> Array:
    var parts := id.split("+")
    if parts.size() < 2: return [id, 0]
    return [parts[0], int(parts[1])]

static func get_item(id: String) -> Dictionary:
    if DB.has(id): return DB[id]
    var parsed := parse_enchant(id)
    if not DB.has(parsed[0]): return {}
    var d: Dictionary = DB[parsed[0]].duplicate(true)
    if d.get("type", "") == "weapon":
        d["damage"] = int(d.get("damage", 5) * enchant_multiplier(parsed[1]))
    return d

static func item_name(id: String) -> String:
    var parsed := parse_enchant(id)
    if DB.has(id): return DB[id].get("name", id)
    if DB.has(parsed[0]):
        return "%s %s" % [DB[parsed[0]].get("name", parsed[0]), ENCHANT_NAMES.get(parsed[1], "+%d" % parsed[1])]
    return id

static func max_stack(id: String) -> int:
    var d := get_item(id)
    return int(d.get("stack", 1))
