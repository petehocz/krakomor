extends Area2D
class_name Corpse

const LIFETIME := 900.0

@export var owner_name := ""
@export var owner_id := 0

var loot: Array = []
var gold := 0
var _age := 0.0

@onready var label: Label = $Label

func _ready() -> void:
    add_to_group("corpses")
    _refresh()
    set_process(true)

func _process(delta: float) -> void:
    _age += delta
    if _age >= LIFETIME:
        queue_free()

func _refresh() -> void:
    if label:
        label.text = "Telo: %s (%d predmetu)" % [owner_name, loot.size()]

func request_loot(looter) -> void:
    for i in range(loot.size() - 1, -1, -1):
        var s: Dictionary = loot[i]
        var left := looter.inventory.add(s.id, s.count, looter.player_name)
        if left == 0: loot.remove_at(i)
        else: s.count = left
    if gold > 0:
        looter.gold += gold
        gold = 0
    _refresh()
    if loot.size() == 0 and gold == 0:
        queue_free()
