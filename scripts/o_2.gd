extends Area2D

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	body.breathe()
	$Sprite2D.visible = false
	$BubbleParticles.emitting = true


func _on_bubble_particles_finished() -> void:
	queue_free()
