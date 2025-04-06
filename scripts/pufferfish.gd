extends CharacterBody2D

@export var SPEED = 100
@export var health = 4
@onready var blood_particles = $BloodParticles
@onready var sprite = $Sprite2D

func _ready() -> void:
	velocity = Vector2.ONE * SPEED
	if randi_range(0, 1):
		velocity.y *= -1

func _process(delta: float) -> void:
	rotation += randf_range(0, 0.25)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * SPEED * delta)
	if collision:
		health -= 1
		if health <= 0:
			queue_free()
		velocity = velocity.bounce(collision.get_normal())

func hit():
	blood_particles.emitting = true
	sprite.visible = false
	$DeathSFX.playing = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		return
	elif body.collision_layer == 1:
		body.hit()


func _on_blood_particles_finished() -> void:
	if health <= 0:
		queue_free()
