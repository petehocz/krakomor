extends CanvasLayer

@onready var skills_list: VBoxContainer = $SkillsPanel/SkillsList
@onready var host_btn: Button = $HostButton
@onready var join_btn: Button = $JoinButton

func _ready() -> void:
    if host_btn: host_btn.pressed.connect(func(): NetworkManager.host_game("Hrac"); _disable())
    if join_btn: join_btn.pressed.connect(func(): NetworkManager.join_game("127.0.0.1", "Hrac"); _disable())

func _disable() -> void:
    host_btn.disabled = true
    join_btn.disabled = true

func _process(_delta: float) -> void:
    if skills_list == null: return
    var local = null
    for p in NetworkManager.players.values():
        if p.is_local: local = p; break
    if local == null or local.skills == null: return
    for c in skills_list.get_children(): c.queue_free()
    for k in ["swordsmanship", "mining", "carpentry", "herbalism"]:
        var lbl := Label.new()
        lbl.text = "%s: %.1f" % [k, local.skills.skills[k]]
        skills_list.add_child(lbl)
    var hp := Label.new()
    hp.text = "HP: %d / %d  |  Mana: %d" % [int(local.hp), int(local.max_hp), int(local.mana)]
    skills_list.add_child(hp)
