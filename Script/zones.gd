extends Area2D
class_name Zone

@export var zone_name: String = "Zone1"

signal broadcast_player_zone(zone_name: String, is_inside: bool)

var player_inside: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	add_to_group("Zone")  # generic group, same for ALL zones
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inside = true
		player_ref = body
		broadcast_player_zone.emit(zone_name, true)
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inside = false
		player_ref = null
		broadcast_player_zone.emit(zone_name, false)
