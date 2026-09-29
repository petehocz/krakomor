extends CanvasLayer

@onready var skills_list: VBoxContainer = $SkillsPanel/SkillsList
@onready var host_btn: Button = $HostButton
@onready var join_btn: Button = $JoinButton
@onready var craft_btn: Button = $CraftButton

func _ready() -> void:
    if host_btn: host_btn.pressed.connect(func(): NetworkManager.host_game("Hrac"); _disable())
    if join_btn: join_btn.pressed.connect(func(): NetworkManager.join_game("127.0.0.1", "Hrac"); _disable())
    if craft_btn: craft_btn.pressed.connect(_on_craft)

func _disable() -> void:
    if host_btn: host_btn.disabled = true
    if join_btn: join_btn.disabled = true

func _local():
    for p in NetworkManager.players.values():
        if p.is_local: return p
    return null

func _on_craft() -> void:
    var p = _local()
    if p == null: return
    if p.near_station == "anvil":
        Recipes.craft("lockpick", p.inventory)
    elif p.near_station == "furnace":
        Recipes.craft("iron_ingot", p.inventory)
    elif p.near_station == "loom":
        Recipes.craft("bandage_linen", p.inventory)

func _process(_delta: float) -> void:
    if skills_list == null: return
    var p = _local()
    if p == null or p.skills == null: return
    for c in skills_list.get_children(): c.queue_free()
    for k in ["swordsmanship", "mining", "blacksmithing", "tailoring", "lockpicking", "healing", "magery"]:
        var lbl := Label.new()
        lbl.text = "%s: %.1f" % [k, p.skills.skills[k]]
        skills_list.add_child(lbl)
    var hp := Label.new()
    hp.text = "HP: %d / %d  |  Mana: %d  |  Zlato: %d" % [int(p.hp), int(p.max_hp), int(p.mana), p.gold]
    skills_list.add_child(hp)
    var station := Label.new()
    station.text = "Stanice: %s" % (p.near_station if p.near_station != "" else "-")
    skills_list.add_child(station)
