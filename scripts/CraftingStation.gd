extends Area2D
class_name CraftingStation

@export var station_type := "anvil"

@onready var label: Label = $Label

func _ready() -> void:
    add_to_group("crafting_stations")
    if label: label.text = station_type
