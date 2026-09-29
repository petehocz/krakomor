extends CharacterBody2D
class_name NPC

signal died

enum Aggro { PASSIVE, DEFENSIVE, AGGRO_ON_SIGHT, TERRITORIAL }

@export var npc_id := "wolf"
@export var npc_name := "Vlk"
@export var max_hp := 30.0
@export var hp := 30.0
@export var damage := 4.0
@export var speed := 80.0
@export var attack_range := 32.0
@export var attack_cooldown := 1.2
@export var vision_range := 200.0
@export var aggro_type: int = Aggro.AGGRO_ON_SIGHT
@export var is_in_dungeon := false
@export var level := 1

var _cd := 0.0
var _target: Player = null
var _spawn_home: Vector2
var _wander_target: Vector2
var _wander_timer := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
    add_to_group("npcs")
    hp = max_hp
    _spawn_home = global_position
    _wander_target = global_position
    if label: label.text = npc_name

func _physics_process(delta: float) -> void:
    if _cd > 0.0: _cd -= delta
    if not multiplayer.has_multiplayer_peer() or multiplayer.is_server():
        _server_ai(delta)

func _server_ai(delta: float) -> void:
    _update_target()
    if _target:
        _chase_and_attack(delta)
    else:
        _wander(delta)

func _update_target() -> void:
    var best: Player = null
    var best_d := vision_range
    for p in get_tree().get_nodes_in_group("players"):
        if p.hp <= 0: continue
        var d := global_position.distance_to(p.global_position)
        if d > best_d: continue
        if is_in_dungeon:
            best = p; best_d = d; continue
        var pl := int(p.skills.total_points() / 50.0)
        if level >= pl + 2 or p == _target:
            best = p; best_d = d
    _target = best

func _chase_and_attack(_delta: float) -> void:
    if _target == null or not is_instance_valid(_target):
        _target = null; return
    var to := _target.global_position - global_position
    if to.length() > attack_range:
        velocity = to.normalized() * speed
        move_and_slide()
    else:
        velocity = Vector2.ZERO
        if _cd <= 0.0:
            _cd = attack_cooldown
            _target.take_damage(damage, self)

func _wander(delta: float) -> void:
    _wander_timer -= delta
    if _wander_timer <= 0.0:
        _wander_timer = randf_range(2.0, 5.0)
        _wander_target = _spawn_home + Vector2(randf_range(-80, 80), randf_range(-80, 80))
    var to := _wander_target - global_position
    if to.length() > 8.0:
        velocity = to.normalized() * speed * 0.4
        move_and_slide()
    else:
        velocity = Vector2.ZERO

func take_damage(amount: float, attacker = null) -> void:
    hp -= amount
    if attacker: _target = attacker
    if hp <= 0.0:
        if attacker:
            attacker.skills.try_gain("swordsmanship", 1.0)
        died.emit()
        queue_free()
