extends CharacterBody2D

class_name Player

signal healthChanged

@onready var healthbar: ProgressBar = $Healthbar
@onready var weapon_hitbox: Area2D = $Hand/Node2D/Sprite2D/weaponHitbox
@export var speed: float = 200.0
@export var camera: Camera2D

var max_health = 100
var health = 100
var attacking = false
var is_dead = false
var stage = 1
var death_position: Vector2

func _ready():
	health = max_health
	is_dead = false
	GameState.player_alive = true

	if is_instance_valid(healthbar):
		healthbar.init_health(max_health)

	if is_instance_valid(weapon_hitbox):
		weapon_hitbox.monitoring = false
		weapon_hitbox.add_to_group("weapon_hitbox")
	else:
		print("Weapon hitbox not found! Check node path.")

func _process(delta):
	if is_dead:
		return  # Prevent input/movement when dead

	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	input_vector = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
	velocity = input_vector
	move_and_slide()

	if input_vector.x != 0:
		$AnimatedSprite2D.flip_h = input_vector.x < 0

	# Aim hand towards mouse
	var arrow = $Hand
	if arrow:
		var mouse_pos = get_global_mouse_position()
		var angle = (mouse_pos - global_position).angle()
		arrow.rotation = angle
		arrow.position = Vector2.RIGHT.rotated(angle) * 3.5

	if camera:
		camera.position = position

func _input(event):
	if is_dead:
		return

	if event.is_action_pressed("basic_attack"):
		attacking = true
		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = true
	elif event.is_action_released("basic_attack"):
		attacking = false
		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = false

func set_damage(amount):
	$Hand/Node2D/Sprite2D/Area2D.damage = amount  # Only call this if node exists

func take_damage(damage):
	if is_dead:
		return

	health -= damage

	if is_instance_valid(healthbar):
		healthbar._set_health(health)

	emit_signal("healthChanged", health)

	if health <= 0:
		health = 0
		is_dead = true
		GameState.player_alive = false
		death_position = position

		$AnimatedSprite2D.visible = false
		if is_instance_valid(healthbar):
			healthbar.hide()

		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = false

		print("Unit is dead!")
		stage += 1

		await get_tree().create_timer(5.0).timeout

		if stage <= 5:
			respawn()
		else:
			get_tree().change_scene_to_file("res://Scenes/YouDIEDMOTHERFUCKA.tscn")

func respawn():
	position = death_position
	health = max_health
	is_dead = false
	GameState.player_alive = true

	if is_instance_valid(healthbar):
		healthbar.show()
		healthbar._set_health(health)

	$AnimatedSprite2D.visible = true
	emit_signal("healthChanged", health)
