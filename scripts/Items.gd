class_name Items
extends RefCounted

const DB := {
    "coal_ore":    {"name": "Uhli",          "type": "ore", "tier": 0, "value": 2,  "stack": 100, "skill": "mining", "min_skill": 0},
    "stone":       {"name": "Kamen",         "type": "ore", "tier": 0, "value": 1,  "stack": 100, "skill": "mining", "min_skill": 0},
    "iron_ore":    {"name": "Zelezna ruda",  "type": "ore", "tier": 1, "value": 3,  "stack": 100, "skill": "mining", "min_skill": 0},
    "copper_ore":  {"name": "Medena ruda",   "type": "ore", "tier": 1, "value": 4,  "stack": 100, "skill": "mining", "min_skill": 0},
    "silver_ore":  {"name": "Stribrna ruda", "type": "ore", "tier": 2, "value": 15, "stack": 100, "skill": "mining", "min_skill": 30},
    "gold_ore":    {"name": "Zlata ruda",    "type": "ore", "tier": 3, "value": 40, "stack": 100, "skill": "mining", "min_skill": 50},
    "oak_log":     {"name": "Dubovy kmen",   "type": "log", "tier": 1, "value": 3,  "stack": 50,  "skill": "carpentry", "min_skill": 0},
    "ash_log":     {"name": "Jasanovy kmen", "type": "log", "tier": 2, "value": 6,  "stack": 50,  "skill": "carpentry", "min_skill": 20},
    "herb_common": {"name": "Kopriva",       "type": "herb","tier": 0, "value": 1,  "stack": 200, "skill": "herbalism", "min_skill": 0},
    "herb_mint":   {"name": "Mata",          "type": "herb","tier": 0, "value": 2,  "stack": 200, "skill": "herbalism", "min_skill": 0},
    "fish_minnow": {"name": "Slunka",        "type": "fish","tier": 0, "value": 2,  "stack": 50,  "skill": "fishing", "min_skill": 0},
    "iron_ingot":  {"name": "Zelezny ingot", "type": "ingot","tier": 1, "value": 12, "stack": 50},
    "leather":     {"name": "Kuze",          "type": "mat",  "tier": 1, "value": 5,  "stack": 50},
    "cloth":       {"name": "Latka",         "type": "mat",  "tier": 1, "value": 6,  "stack": 50},
    "lockpick":    {"name": "Paklic",        "type": "key",  "tier": 1, "value": 5,  "stack": 100},
    "bread":       {"name": "Chleb",         "type": "food", "tier": 0, "value": 5,  "stack": 20},
    "iron_sword":  {"name": "Zelezny mec",   "type": "weapon","tier": 1, "damage": 10, "value": 80, "stack": 1},
    "linen_shirt": {"name": "Lnena kosile",  "type": "armor", "tier": 0, "armor": 1, "value": 20, "stack": 1},
    "bandage":     {"name": "Obvaz",         "type": "consumable", "tier": 1, "value": 8, "stack": 50},
    "bandage_linen":{"name": "Lneny obvaz",  "type": "consumable", "tier": 0, "value": 4, "stack": 50},
    "reagent_blood":{"name": "Krev",         "type": "reagent", "tier": 1, "value": 3, "stack": 100},
    "reagent_ash": {"name": "Popel",         "type": "reagent", "tier": 1, "value": 2, "stack": 200},
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
    elif d.get("type", "") == "armor":
        d["armor"] = int(d.get("armor", 1) * enchant_multiplier(parsed[1]))
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
