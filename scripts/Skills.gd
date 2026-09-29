class_name Skills
extends Node

const TOTAL_CAP := 700.0
const ALL_SKILLS := [
    "swordsmanship", "archery", "parrying", "macefighting", "fencing",
    "blacksmithing", "carpentry", "tailoring", "cooking", "tinkering",
    "mining", "herbalism", "fishing", "lumberjacking",
    "trade", "bartering", "item_id",
    "alchemy", "healing", "literacy", "magery", "resisting_spells",
    "tracking", "riding", "animal_taming",
    "lockpicking", "stealing", "hiding",
]

enum State { RISING, HOLDING, FALLING }

var skills := {}
var states := {}

func _ready() -> void:
    for k in ALL_SKILLS:
        skills[k] = 0.0
        states[k] = State.RISING

static func gain_rate(current: float) -> float:
    if current < 30.0: return 1.0
    elif current < 70.0: return 0.5
    elif current < 95.0: return 0.15
    return 0.05

func total_points() -> float:
    var t := 0.0
    for v in skills.values(): t += v
    return t

func try_gain(skill: String, amount: float = 1.0) -> void:
    if not skills.has(skill) or states[skill] != State.RISING: return
    if total_points() >= TOTAL_CAP: return
    skills[skill] = min(100.0, skills[skill] + amount * gain_rate(skills[skill]))

func strength() -> int:   return int(10 + skills["swordsmanship"]*0.5 + skills["mining"]*0.3)
func dexterity() -> int:  return int(10 + skills["tracking"]*0.4 + skills["archery"]*0.4)
func endurance() -> int:  return int(10 + skills["mining"]*0.5)
func intellect() -> int:  return int(10 + skills["alchemy"]*0.6 + skills["literacy"]*0.5)
