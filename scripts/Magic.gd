class_name Magic
extends RefCounted

const SPELLS := {
    "magic_bolt": {"name": "Magicka strela", "mana_cost": 8, "min_skill": 0, "damage": 10},
    "fire_arrow": {"name": "Ohnivy sip", "mana_cost": 15, "min_skill": 20, "damage": 22},
    "ice_spike": {"name": "Ledovy hrot", "mana_cost": 22, "min_skill": 40, "damage": 32},
    "summon_dragon": {"name": "Vyvolani draka", "mana_cost": 150, "min_skill": 95, "damage": 0},
}

static func can_cast(spell_id: String, player) -> Dictionary:
    var s := SPELLS.get(spell_id, {})
    if s.is_empty(): return {"ok": false, "reason": "unknown"}
    if player.skills.skills.get("magery", 0.0) < float(s.get("min_skill", 0)):
        return {"ok": false, "reason": "low_skill"}
    if player.mana < float(s["mana_cost"]):
        return {"ok": false, "reason": "no_mana"}
    return {"ok": true}

static func cast(spell_id: String, player, target = null) -> Dictionary:
    var check := can_cast(spell_id, player)
    if not check.ok: return check
    var s: Dictionary = SPELLS[spell_id]
    player.mana -= float(s["mana_cost"])
    if target and is_instance_valid(target) and s.has("damage") and s["damage"] > 0:
        if target.has_method("take_damage"):
            target.take_damage(float(s["damage"]), player)
    player.skills.try_gain("magery", 1.0)
    return {"ok": true}
