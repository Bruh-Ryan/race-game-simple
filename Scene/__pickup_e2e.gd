extends Node
## Throwaway E2E: real Player + real Item + autoload Global.
## E is held across several idle frames (like a human press).

var failures := 0
var frames := 0
var item = null


func check(cond: bool, name: String) -> void:
	if cond:
		print("PASS: ", name)
	else:
		failures += 1
		printerr("FAIL: ", name)


func _ready() -> void:
	Global.start_run()
	var player := load("res://Scene/Player.tscn").instantiate() as Node2D
	player.position = Vector2(500, 500)
	add_child(player)
	item = load("res://Scene/Items/Item.tscn").instantiate()
	item.set("position", Vector2(500, 500))
	item.set("item_type", "coin")
	item.set("item_name", "Coin")
	add_child(item)
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(bool(item.get("ALLOW_PICKUP")), "area detects player")
	Input.action_press("pickup")


func _process(_delta: float) -> void:
	frames += 1
	if frames == 4:
		Input.action_release("pickup")
	if frames == 6:
		check(Global.items_collected == 1, "E pickup bumps quota")
		check(Global.inventory[0] != null and Global.inventory[0].get("item_quantity") == 1, "E pickup lands in slot")
		check(not is_instance_valid(item), "E pickup frees item")
		print("FAILURES: ", failures)
		get_tree().quit(failures)
