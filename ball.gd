extends RigidBody3D

var spawn_point

func _ready():
	mass = 0.165
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	spawn_point = global_position
