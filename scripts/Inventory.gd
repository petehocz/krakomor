class_name Inventory
extends Node

signal changed
var slots: Array = []
const MAX_SLOTS := 30

func _ready() -> void:
    slots.resize(MAX_SLOTS)
    for i in range(MAX_SLOTS): slots[i] = null

func add(item_id: String, count: int = 1, owner_name: String = "") -> int:
    var left := count
    for i in range(MAX_SLOTS):
        if left <= 0: break
        var s = slots[i]
        if s != null and s.id == item_id:
            var space := Items.max_stack(item_id) - s.count
            if space > 0:
                var put = min(space, left)
                s.count += put
                left -= put
    for i in range(MAX_SLOTS):
        if left <= 0: break
        if slots[i] == null:
            var cap := Items.max_stack(item_id)
            var put = min(cap, left)
            slots[i] = {"id": item_id, "count": put}
            left -= put
    changed.emit()
    return left

func remove(item_id: String, count: int = 1) -> bool:
    if count_of(item_id) < count: return false
    var left := count
    for i in range(MAX_SLOTS):
        if left <= 0: break
        var s = slots[i]
        if s != null and s.id == item_id:
            var take = min(s.count, left)
            s.count -= take
            left -= take
            if s.count <= 0: slots[i] = null
    changed.emit()
    return true

func count_of(item_id: String) -> int:
    var n := 0
    for s in slots:
        if s != null and s.id == item_id: n += s.count
    return n

func dump_all() -> Array:
    var out := []
    for s in slots:
        if s != null: out.append(s.duplicate(true))
    for i in range(MAX_SLOTS): slots[i] = null
    changed.emit()
    return out

func to_save() -> Array: return slots.duplicate(true)
func from_save(data: Array) -> void:
    slots.resize(MAX_SLOTS)
    for i in range(MAX_SLOTS):
        slots[i] = data[i] if i < data.size() else null
    changed.emit()
