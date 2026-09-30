extends CanvasLayer
## Score HUD: survival time IS the score. Hold the inventory key (T) to peek
## at the item/key counts. Clock starts here until GameManager owns it (step 2).

@onready var score_label: Label = $TimeLabel
@onready var inventory_panel: Control = $InventoryPanel
@onready var inv_items_label: Label = $InventoryPanel/ItemsLabel
@onready var inv_keys_label: Label = $InventoryPanel/KeyLabel


func _ready() -> void:
	# Starts the run clock. Moves to GameManager in step 2.
	Global.start_run()
	Global.inventory_updated.connect(_render_inventory)
	score_label.text = "Score " + Global.get_run_time_text()
	inventory_panel.visible = false
	_render_inventory()


func _process(_delta: float) -> void:
	score_label.text = "Score " + Global.get_run_time_text()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_panel.visible = true
	elif event.is_action_released("inventory"):
		inventory_panel.visible = false


func _render_inventory() -> void:
	var coins := 0
	var keys: Array[String] = []
	for slot in Global.inventory:
		if slot == null:
			continue
		if slot.get("item_type") == "coin":
			coins += int(slot.get("item_quantity", 0))
		elif str(slot.get("item_type", "")).begins_with("key"):
			keys.append(str(slot.get("item_name", "key")))
	inv_items_label.text = "Items: %d" % coins
	inv_keys_label.text = "Keys: %s" % (", ".join(keys) if not keys.is_empty() else "-")
