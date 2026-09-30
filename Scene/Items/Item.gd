extends Node2D
## World pickup: player walks into Collection_Area, presses E (pickup action).

@export var item_type := "coin"
@export var item_name := "Coin"
@export var item_effect := ""
@export var item_texture: Texture2D

var ALLOW_PICKUP := false
@onready var item_sp: Sprite2D = $Sprite


func _ready() -> void:
	# Only override the scene texture when one is actually assigned.
	if item_texture != null:
		item_sp.texture = item_texture


func _process(_delta: float) -> void:
	if ALLOW_PICKUP and Input.is_action_just_pressed("pickup"):
		pickup()


func pickup() -> void:
	var item := {
		"item_type": item_type,
		"item_name": item_name,
		"item_quantity": 1,
		"item_effect": item_effect,
		"item_texture": item_texture,
	}
	# add_item is false when the inventory is full: item stays in the world.
	if Global.add_item(item):
		Global.register_item()
		if item_type.begins_with("key"):
			Global.register_key()
		queue_free()


func _on_collection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ALLOW_PICKUP = true
		body.interactive_UI.visible = true


func _on_collection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ALLOW_PICKUP = false
		body.interactive_UI.visible = false
