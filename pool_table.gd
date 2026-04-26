extends StaticBody3D



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("balls"):
		body.queue_free()
	if body.is_in_group("cueBall"):
		body.freeze = true
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.global_position = body.spawn_point
		body.freeze = false
