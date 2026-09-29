class_name Healing
extends RefCounted

static func apply_bandage(healer, target, bandage_id: String) -> Dictionary:
    var data := Items.get_item(bandage_id)
    if data.is_empty() or data.get("type", "") != "consumable":
        return {"ok": false, "reason": "invalid"}
    if healer.inventory.count_of(bandage_id) <= 0:
        return {"ok": false, "reason": "no_bandage"}
    if target.hp >= target.max_hp:
        return {"ok": false, "reason": "full_hp"}
    healer.inventory.remove(bandage_id, 1)
    target.hp = min(target.max_hp, target.hp + 20)
    healer.skills.try_gain("healing", 1.5)
    return {"ok": true}
