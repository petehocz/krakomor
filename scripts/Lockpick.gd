class_name Lockpick
extends RefCounted

static func chance(skill_value: float, lock_difficulty: int) -> float:
    var base := 0.05 + skill_value * 0.009
    return clamp(base - lock_difficulty * 0.08, 0.02, 0.95)

static func attempt(player, lock_difficulty: int) -> Dictionary:
    if player.inventory.count_of("lockpick") <= 0:
        return {"success": false, "reason": "no_lockpick"}
    var skill_value: float = player.skills.skills.get("lockpicking", 0.0)
    if randf() < chance(skill_value, lock_difficulty):
        player.skills.try_gain("lockpicking", 2.0)
        return {"success": true}
    player.inventory.remove("lockpick", 1)
    player.skills.try_gain("lockpicking", 0.5)
    return {"success": false, "broke": true}
