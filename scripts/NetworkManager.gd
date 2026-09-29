extends Node

const PORT := 7000
const MAX_PLAYERS := 128
const AUTOSAVE_INTERVAL := 60.0

signal player_joined(id: int, name: String)
signal player_left(id: int)

var is_server := false
var players := {}
var _autosave_timer: Timer

func host_game(player_name: String) -> void:
    var peer := ENetMultiplayerPeer.new()
    if peer.create_server(PORT, MAX_PLAYERS) != OK:
        push_error("Nelze spustit server")
        return
    multiplayer.multiplayer_peer = peer
    is_server = true
    if _autosave_timer == null:
        _autosave_timer = Timer.new()
        _autosave_timer.wait_time = AUTOSAVE_INTERVAL
        _autosave_timer.autostart = true
        _autosave_timer.timeout.connect(_autosave_all)
        add_child(_autosave_timer)
    _spawn_player(1, player_name, true, Persistence.load_player(player_name))
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func join_game(ip: String, player_name: String) -> void:
    var peer := ENetMultiplayerPeer.new()
    if peer.create_client(ip, PORT) != OK:
        push_error("Nelze se pripojit")
        return
    multiplayer.multiplayer_peer = peer
    is_server = false
    _spawn_player(multiplayer.get_unique_id(), player_name, true, {})

func _on_peer_connected(id: int) -> void:
    _spawn_player(id, "Hrac_%d" % id, false, {})

func _on_peer_disconnected(id: int) -> void:
    if players.has(id):
        Persistence.save_player(players[id].player_name, players[id].to_save())
        players[id].queue_free()
        players.erase(id)
    player_left.emit(id)

func _spawn_player(id: int, pname: String, local: bool, data: Dictionary) -> void:
    var scene: PackedScene = load("res://scenes/Player.tscn")
    if scene == null: return
    var p = scene.instantiate()
    p.name = "Player_%d" % id
    p.player_name = pname
    p.peer_id = id
    p.is_local = local
    if data.has("position"):
        p.global_position = Vector2(data.position[0], data.position[1])
    else:
        p.global_position = Vector2(randf_range(-50, 50), randf_range(-50, 50))
    var world := get_tree().get_first_node_in_group("world")
    if world: world.add_child(p)
    p.apply_save(data)
    players[id] = p
    player_joined.emit(id, pname)

func find_by_name(pname: String):
    for p in players.values():
        if p.player_name == pname: return p
    return null

func _autosave_all() -> void:
    if not is_server: return
    for p in players.values():
        Persistence.save_player(p.player_name, p.to_save())
