extends CharacterBody2D

@export var SPEED = 200
@export var ACCELERATION = 30
@export var health = 2

@onready var player = $"../Player"
@onready var timer = $Timer
@onready var sprite = $AnimatedSprite2D
@onready var blood_particles = $BloodParticles
@onready var charge_sfx = $ChargeSFX
@onready var hurt_sfx = $HurtSFX

var target_position = Vector2.ZERO
var last_distnace = 99999

var is_attacking = false
var direction = Vector2()

func _ready():
	timer.start(randf_range(2.5, 3.5))

func _physics_process(_delta):
	if not is_attacking:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
		velocity.y = move_toward(velocity.y, 0, ACCELERATION)
		look_at(player.position)
		if rotation < deg_to_rad(90) and rotation > deg_to_rad(-90):
			sprite.flip_v = false
		else:
			sprite.flip_v = true
	else:
		var new_distance = position.distance_to(target_position)
		if new_distance < last_distnace:
			last_distnace = new_distance
		else:
			is_attacking = false
			last_distnace = 99999
			timer.start()
			sprite.play("idle")
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.name == "TileMapLayer":
		sprite.play("idle")
		is_attacking = false
		timer.start()
	elif body.collision_layer == 1:
		body.hit()

func hit():
	health -= 1
	blood_particles.emitting = true
	if health <= 0:
		sprite.visible = false
		$DeathSFX.playing = true
	else:
		hurt_sfx.playing = true

func _on_timer_timeout() -> void:
	sprite.play("attack")
	charge_sfx.playing = true
	target_position = player.position
	direction = position.direction_to(player.position)
	velocity = direction * SPEED
	is_attacking = true


func _on_blood_particles_finished() -> void:
	if health <= 0:
		queue_free()
