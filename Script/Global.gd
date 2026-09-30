extends Node
## Global run state (autoload singleton, registered in project.godot as "Global").
## Owns the survival clock, per-run counters and persisted records.


signal run_started
signal run_stopped(run_time: float)
signal stage_changed(new_stage: int)
signal kill_registered(total_kills: int)
signal item_registered(total_items: int)
signal key_registered(total_keys: int)

const TOTAL_STAGES := 5
const SAVE_PATH := "user://record.cfg"
const INVENTORY_SIZE := 9
const STACKABLE_ITEMS := ["coin"]

var run_active: bool = false
var run_time: float = 0.0
var current_stage: int = 1
var kills: int = 0
var items_collected: int = 0
var keys_held: int = 0
var inventory = []

var best_time: float = 0.0
var best_stage: int = 0

signal inventory_updated

var player_node : Node = null

func _ready() -> void:
	load_records()
	reset_inventory()


func _process(delta: float) -> void:
	if run_active:
		run_time += delta

func set_player_refference(player):
	player_node = player
## ---- run lifecycle -------------------------------------------------------

func start_run() -> void:
	run_time = 0.0
	current_stage = 1
	kills = 0
	items_collected = 0
	keys_held = 0
	reset_inventory()
	run_active = true
	run_started.emit()


func reset_run() -> void:
	start_run()


func stop_run(stages_completed: int) -> void:
	run_active = false
	if run_time > best_time:
		best_time = run_time
	if stages_completed > best_stage:
		best_stage = stages_completed
	save_records()
	run_stopped.emit(run_time)


## ---- survival clock ------------------------------------------------------

func get_run_time() -> float:
	return run_time


func get_run_time_text() -> String:
	var m := int(run_time) / 60
	var s := int(run_time) % 60
	return "%02d:%02d" % [m, s]


func get_best_time_text() -> String:
	var m := int(best_time) / 60
	var s := int(best_time) % 60
	return "%02d:%02d" % [m, s]


## ---- counters ------------------------------------------------------------

func set_stage(stage_number: int) -> void:
	current_stage = clampi(stage_number, 1, TOTAL_STAGES)
	stage_changed.emit(current_stage)


func register_kill() -> void:
	kills += 1
	kill_registered.emit(kills)


func register_item() -> void:
	items_collected += 1
	item_registered.emit(items_collected)


func register_key() -> void:
	keys_held += 1
	key_registered.emit(keys_held)


## ---- records -------------------------------------------------------------

func load_records() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_time = float(cfg.get_value("records", "best_time", 0.0))
		best_stage = int(cfg.get_value("records", "best_stage", 0))


func save_records() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("records", "best_time", best_time)
	cfg.set_value("records", "best_stage", best_stage)
	cfg.save(SAVE_PATH)

## ---- player inventory ------------------------------------------------------
## Slots hold null or {"item_type", "item_name", "item_quantity",
## "item_effect", "item_texture"}. Coins stack, keys take their own slots.
## Pickup flow: Item.pickup() -> add_item() + register_item()/register_key().

func reset_inventory() -> void:
	inventory.clear()
	inventory.resize(INVENTORY_SIZE)
	inventory_updated.emit()


func add_item(item: Dictionary) -> bool:
	# Stack coins onto their existing slot.
	if item.get("item_type") in STACKABLE_ITEMS:
		for slot in inventory:
			if slot is Dictionary and slot.get("item_type") == item.get("item_type") \
			and slot.get("item_effect") == item.get("item_effect"):
				slot["item_quantity"] = int(slot.get("item_quantity", 0)) + int(item.get("item_quantity", 1))
				print("item added :", inventory)
				inventory_updated.emit()
				return true
	# Otherwise take the first empty slot.
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			print("item added :", inventory)
			inventory_updated.emit()
			return true
	return false


func remove_item(slot: int) -> void:
	if slot < 0 or slot >= inventory.size():
		return
	var entry = inventory[slot]
	if entry == null:
		return
	entry["item_quantity"] = int(entry.get("item_quantity", 1)) - 1
	if entry["item_quantity"] <= 0:
		inventory[slot] = null
	inventory_updated.emit()
			
