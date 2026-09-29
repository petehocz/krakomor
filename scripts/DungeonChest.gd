extends Area2D
class_name DungeonChest

@export var lock_difficulty := 1
var opened := false
var boss_dead := false

@onready var label: Label = $Label

func _ready() -> void:
    add_to_group("chests")
    _refresh()

func _refresh() -> void:
    if label == null: return
    if opened: label.text = "Otevreno"
    elif not boss_dead: label.text = "Truhla (zamceno bossem)"
    else: label.text = "Truhla (odemkni paklicem)"

func set_boss_dead() -> void:
    boss_dead = true
    _refresh()

func request_open(player) -> void:
    if opened: return
    if not boss_dead:
        if label: label.text = "Nejdriv zabij bosse!"
        return
    if player.inventory.count_of("lockpick") <= 0:
        if label: label.text = "Nemas paklic!"
        return
    var res := Lockpick.attempt(player, lock_difficulty)
    if res.success:
        opened = true
        player.gold += randi_range(50, 200) * lock_difficulty
        player.inventory.add("iron_ingot", randi_range(2, 5))
        _refresh()
    else:
        if label: label.text = "Paklic se zlomil!"
