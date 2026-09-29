extends Area2D
class_name Dungeon

@export var dungeon_id := "d1"
@export var dungeon_level := 1

var is_active := true
var _respawn_timer := 0.0
var _completed := false

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    add_to_group("dungeons")
    _refresh()

func _refresh() -> void:
    if label == null: return
    if is_active:
        label.text = "Dungeon %d" % dungeon_level
        if sprite: sprite.modulate = Color(0.4, 0.6, 1.0)
    else:
        label.text = ""
        if sprite: sprite.modulate = Color(0.2, 0.2, 0.2, 0.3)

func mark_completed() -> void:
    is_active = false
    _completed = true
    _refresh()
    _respawn_timer = randf_range(600.0, 1800.0)
    set_process(true)

func _process(delta: float) -> void:
    if not _completed: return
    _respawn_timer -= delta
    if _respawn_timer <= 0.0:
        var rng := RandomNumberGenerator.new()
        rng.randomize()
        global_position = Vector2(rng.randf_range(2000, 28000), rng.randf_range(2000, 28000))
        is_active = true
        _completed = false
        _refresh()
        set_process(false)
