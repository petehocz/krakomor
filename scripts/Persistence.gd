class_name Persistence
extends RefCounted

const SAVE_DIR := "user://saves"

static func ensure_dir() -> void:
    if not DirAccess.dir_exists_absolute(SAVE_DIR):
        DirAccess.make_dir_recursive_absolute(SAVE_DIR)

static func atomic_write(path: String, content: String) -> void:
    ensure_dir()
    var tmp := path + ".tmp"
    var f := FileAccess.open(tmp, FileAccess.WRITE)
    if not f: return
    f.store_string(content)
    f.close()
    var da := DirAccess.open("user://saves")
    if da: da.rename(tmp, path)

static func save_player(pname: String, data: Dictionary) -> void:
    var path := "%s/%s.json" % [SAVE_DIR, pname.validate_filename()]
    atomic_write(path, JSON.stringify(data, "  "))

static func load_player(pname: String) -> Dictionary:
    var path := "%s/%s.json" % [SAVE_DIR, pname.validate_filename()]
    if not FileAccess.file_exists(path): return {}
    var f := FileAccess.open(path, FileAccess.READ)
    if not f: return {}
    var txt := f.get_as_text()
    f.close()
    var parsed = JSON.parse_string(txt)
    return parsed if parsed is Dictionary else {}
