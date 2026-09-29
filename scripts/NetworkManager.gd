extends Node

const PORT := 7000
const MAX_PLAYERS := 128

signal player_joined(id: int, name: String)

var is_server := false
var players := {}

func host_game(player_name: String) -> void:
    var peer := ENetMultiplayerPeer.new()
    if peer.create_server(PORT, MAX_PLAYERS) != OK:
        push_error("Nelze spustit server")
        return
    multiplayer.multiplayer_peer = peer
    is_server = true
    _spawn_player(1, player_name, true)
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func join_game(ip: String, player_name: String) -> void:
    var peer := ENetMultiplayerPeer.new()
    if peer.create_client(ip, PORT) != OK:
        push_error("Nelze se pripojit")
        return
    multiplayer.multiplayer_peer = peer
    is_server = false
    _spawn_player(multiplayer.get_unique_id(), player_name, true)

func _on_peer_connected(id: int) -> void:
    _spawn_player(id, "Hrac_%d" % id, false)

func _on_peer_disconnected(id: int) -> void:
    if players.has(id):
        players[id].queue_free()
        players.erase(id)

func _spawn_player(id: int, pname: String, local: bool) -> void:
    var scene: PackedScene = load("res://scenes/Player.tscn")
    if scene == null: return
    var p = scene.instantiate()
    p.name = "Player_%d" % id
    p.player_name = pname
    p.peer_id = id
    p.is_local = local
    p.global_position = Vector2(randf_range(-50, 50), randf_range(-50, 50))
    var world := get_tree().get_first_node_in_group("world")
    if world: world.add_child(p)
    players[id] = p
    player_joined.emit(id, pname)
