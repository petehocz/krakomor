extends Area2D
class_name Ankh

@export var ankh_name := "Kriz"
@export var hp_on_revive := 30.0

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

var _cd: Dictionary = {}

func _ready() -> void:
    add_to_group("ankhs")
    if label: label.text = ankh_name

func request_revive(player) -> void:
    if not player.is_ghost: return
    if _cd.has(player.player_name) and _cd[player.player_name] > Time.get_unix_time_from_system():
        return
    player.exit_ghost_mode(hp_on_revive)
    _cd[player.player_name] = Time.get_unix_time_from_system() + 300

func _process(_delta: float) -> void:
    if sprite:
        var t := Time.get_ticks_msec() / 1000.0
        sprite.modulate.a = 0.7 + sin(t * 2.0) * 0.3
