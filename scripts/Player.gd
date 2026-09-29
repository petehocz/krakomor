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
var last_dir := Vector2.RIGHT

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
    max_mana = 30.0 + skills.intellect() * 5.0
    mana = min(max_mana, mana + delta * 2.0)
    if not is_local: return
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

func _input(event: InputEvent) -> void:
    if not is_local: return
    if event.is_action_pressed("attack"):
        skills.try_gain("swordsmanship", 1.0)
    if event.is_action_pressed("gather"):
        skills.try_gain("mining", 1.0)

func to_save() -> Dictionary:
    return {"name": player_name, "position": [global_position.x, global_position.y], "hp": hp, "gold": gold}

func apply_save(data: Dictionary) -> void:
    if data.has("position"):
        global_position = Vector2(data.position[0], data.position[1])
    if data.has("hp"): hp = float(data["hp"])
    if data.has("gold"): gold = int(data["gold"])

@rpc("authority", "call_local", "reliable")
func teleport_to(pos: Vector2) -> void:
    global_position = pos
