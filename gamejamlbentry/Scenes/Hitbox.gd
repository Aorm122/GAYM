extends Area2D
class_name Hitbox

@export var damage: int = 1
@export var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 300

@onready var collision_shape: CollisionShape2D = get_child(0)

func _ready() -> void:
	assert(collision_shape != null)
	body_entered.connect(_on_body_entered)
	add_to_group("weapon_hitbox")
	
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
