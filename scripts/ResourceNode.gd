extends Area2D
class_name ResourceNode

@export var resource_type := "iron_ore"
@export var amount_left := 5
@export var respawn_time := 20.0

var _respawn_timer := 0.0
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
    add_to_group("resource_nodes")
    _refresh_visual()

func request_gather(player) -> void:
    if amount_left <= 0: return
    var d := Items.get_item(resource_type)
    var skill := d.get("skill", "mining")
    var min_skill := float(d.get("min_skill", 0.0))
    if player.skills.skills.get(skill, 0.0) < min_skill:
        if label: label.text = "Potrebujes %s %.0f" % [skill, min_skill]
        return
    amount_left -= 1
    player.skills.try_gain(skill, 1.0)
    var count := randi_range(1, 3)
    player.inventory.add(resource_type, count)
    _refresh_visual()
    if amount_left <= 0:
        _respawn_timer = respawn_time
        set_process(true)

func _process(delta: float) -> void:
    if _respawn_timer > 0.0:
        _respawn_timer -= delta
        if _respawn_timer <= 0.0:
            amount_left = 5
            _refresh_visual()
            set_process(false)

func _refresh_visual() -> void:
    if sprite == null: return
    if amount_left <= 0:
        sprite.modulate = Color(0.3, 0.3, 0.3, 0.5)
        if label: label.text = "(vycerpano)"
    else:
        sprite.modulate = Color(0.7, 0.5, 0.3) if "iron" in resource_type else Color(0.4, 0.8, 0.4)
        if label: label.text = "%s [%d]" % [Items.item_name(resource_type), amount_left]
