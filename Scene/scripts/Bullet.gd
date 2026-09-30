extends CharacterBody2D

var speed = 100
var direction = Vector2.ZERO

func _ready():
	add_to_group("Bullets")

func set_direction(dir):
	direction = dir

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		#var hit_object = collision.get_collider()
		#if hit_object.is_in_group("Enemy"):
			#hit_object.queue_free()
		queue_free()
