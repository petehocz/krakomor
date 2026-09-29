extends Area2D
class_name Healer

@export var healer_name := "Ranhojic"
@export var cost_gold := 20
@export var heal_hp := 100.0
@export var revive_cost_gold := 100

@onready var label: Label = $Label

func _ready() -> void:
    add_to_group("healers")
    if label: label.text = healer_name

func heal(player) -> bool:
    if player.hp >= player.max_hp or player.gold < cost_gold: return false
    player.gold -= cost_gold
    player.hp = min(player.max_hp, player.hp + heal_hp)
    return true

func request_revive(player) -> void:
    if not player.is_ghost or player.gold < revive_cost_gold: return
    player.gold -= revive_cost_gold
    player.exit_ghost_mode(50.0)
