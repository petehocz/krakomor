extends CharacterBody2D
class_name Player

@export var speed := 180.0
@export var player_name := "Hrac"

var peer_id: int = 1
var skills: Skills
var inventory: Inventory
var hp := 100.0
var max_hp := 100.0
var mana := 50.0
var max_mana := 50.0
var gold := 50
var is_local := false
var is_ghost := false
var last_dir := Vector2.RIGHT
var attack_cooldown := 0.0
var near_station := ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel

func _ready() -> void:
    skills = Skills.new()
    add_child(skills)
    inventory = Inventory.new()
    add_child(inventory)
    if name_label: name_label.text = player_name
    add_to_group("players")

func _physics_process(delta: float) -> void:
    if attack_cooldown > 0.0: attack_cooldown -= delta
    max_mana = 30.0 + skills.intellect() * 5.0
    if not is_ghost:
        mana = min(max_mana, mana + delta * 2.0)
    if is_local and not is_ghost:
        _detect_nearby()
    if not is_local or is_ghost: return
    var v := Vector2.ZERO
    if Input.is_action_pressed("move_up"):    v.y -= 1
    if Input.is_action_pressed("move_down"):  v.y += 1
    if Input.is_action_pressed("move_left"):  v.x -= 1
    if Input.is_action_pressed("move_right"): v.x += 1
    if v != Vector2.ZERO:
        v = v.normalized()
        last_dir = v
        velocity = v * speed
    else:
        velocity = Vector2.ZERO
    move_and_slide()

func _detect_nearby() -> void:
    near_station = ""
    for s in get_tree().get_nodes_in_group("crafting_stations"):
        if global_position.distance_to(s.global_position) < 60.0:
            near_station = s.station_type
            return

func _input(event: InputEvent) -> void:
    if not is_local or is_ghost: return
    if event.is_action_pressed("attack") and attack_cooldown <= 0.0:
        attack_cooldown = 0.6
        _request_attack()

func _request_attack() -> void:
    var rng := 40.0
    var dmg := 5.0 + skills.skills["swordsmanship"] * 0.15
    for n in get_tree().get_nodes_in_group("npcs"):
        if global_position.distance_to(n.global_position) <= rng:
            skills.try_gain("swordsmanship", 1.0)
            n.take_damage(dmg, self)

func take_damage(amount: float, _attacker = null) -> void:
    if is_ghost: return
    hp = max(0.0, hp - amount)
    if hp <= 0.0: _die()

func _die() -> void:
    _spawn_corpse()
    enter_ghost_mode()

func _spawn_corpse() -> void:
    var scene: PackedScene = load("res://scenes/Corpse.tscn")
    if scene == null: return
    var c = scene.instantiate()
    c.owner_name = player_name
    c.owner_id = peer_id
    c.global_position = global_position
    c.loot = inventory.dump_all()
    c.gold = gold
    gold = 0
    var world := get_tree().get_first_node_in_group("world")
    if world: world.add_child(c)

func enter_ghost_mode() -> void:
    is_ghost = true
    hp = 0.0
    mana = 0.0
    modulate = Color(0.6, 0.7, 1.0, 0.5)
    collision_layer = 0
    collision_mask = 0

func exit_ghost_mode(new_hp: float = 30.0) -> void:
    is_ghost = false
    hp = new_hp
    mana = max_mana * 0.5
    modulate = Color.WHITE
    collision_layer = 1
    collision_mask = 1

func to_save() -> Dictionary:
    return {"name": player_name, "position": [global_position.x, global_position.y], "hp": hp, "gold": gold, "inventory": inventory.to_save()}

func apply_save(data: Dictionary) -> void:
    if data.has("position"): global_position = Vector2(data.position[0], data.position[1])
    if data.has("hp"): hp = float(data["hp"])
    if data.has("gold"): gold = int(data["gold"])
    if data.has("inventory"): inventory.from_save(data["inventory"])

@rpc("authority", "call_local", "reliable")
func teleport_to(pos: Vector2) -> void:
    global_position = pos
