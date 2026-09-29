class_name Recipes
extends RefCounted

const DB := {
    "iron_ingot":   {"input": {"iron_ore": 2, "coal_ore": 1}, "output": {"iron_ingot": 1}, "skill": "blacksmithing", "min_skill": 0, "station": "furnace"},
    "lockpick":     {"input": {"iron_ore": 1}, "output": {"lockpick": 3}, "skill": "blacksmithing", "min_skill": 0, "station": "anvil"},
    "iron_sword":   {"input": {"iron_ingot": 2, "leather": 1}, "output": {"iron_sword": 1}, "skill": "blacksmithing", "min_skill": 20, "station": "anvil"},
    "linen_shirt":  {"input": {"cloth": 3}, "output": {"linen_shirt": 1}, "skill": "tailoring", "min_skill": 0, "station": "loom"},
    "bandage_linen":{"input": {"cloth": 1}, "output": {"bandage_linen": 3}, "skill": "tailoring", "min_skill": 0, "station": "loom"},
    "bandage":      {"input": {"cloth": 2, "herb_common": 1}, "output": {"bandage": 3}, "skill": "tailoring", "min_skill": 15, "station": "loom"},
    "bread":        {"input": {"herb_common": 1}, "output": {"bread": 2}, "skill": "cooking", "min_skill": 0, "station": "hearth"},
}

static func get_recipe(id: String) -> Dictionary:
    return DB.get(id, {})

static func can_craft(recipe_id: String, inv, skill_value: float, near_station: String) -> bool:
    var r := get_recipe(recipe_id)
    if r.is_empty(): return false
    if skill_value < float(r.get("min_skill", 0.0)): return false
    if near_station != String(r.get("station", "")): return false
    for item_id in r["input"].keys():
        if inv.count_of(item_id) < int(r["input"][item_id]): return false
    return true

static func craft(recipe_id: String, inv) -> bool:
    var r := get_recipe(recipe_id)
    if r.is_empty(): return false
    for item_id in r["input"].keys():
        if not inv.remove(item_id, int(r["input"][item_id])): return false
    for item_id in r["output"].keys():
        inv.add(item_id, int(r["output"][item_id]))
    return true
