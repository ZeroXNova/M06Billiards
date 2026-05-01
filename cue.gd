extends RigidBody3D

@export var move_speed = 10.0
@export var turn_speed = 2.0
@export var fixed_height = 4
@export var min_force = 2.0
@export var max_force = 12.0
@export var charge_rate = 8.0
@export var max_pullback = 5
@export var snap_speed = 20.0

var charge = 0.0
var charging = false
var rest_position : Vector3
var pull_offset = 0.0
var snapping = false
var move_dir = Vector3.ZERO
var lock_height = true
var shot_lock = false
var shooting = false
var shot_velocity = Vector3.ZERO
var shot_time = 0.0
var shot_duration = 0.1

func _ready():
	pass
	
func _physics_process(delta):
	if shot_lock or charging or snapping:
		return
	linear_velocity.y = 0
	global_position.y = fixed_height

func _process(delta):
	cue_movement(delta)
	cue_rotation(delta)
	shot_charge(delta)
	if not charging and not snapping and not shot_lock:
		if rest_position == Vector3.ZERO:
			rest_position = global_position
			lock_height = true
	else:
		lock_height = false
	if shooting:
		shot_time += delta

		if shot_time >= shot_duration:
			shooting = false
		else:
			global_position -= shot_velocity * delta

func cue_movement(delta):
	if charging:
		return
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		input_dir.z += 1
	if Input.is_action_pressed("back"):
		input_dir.z -= 1
	if Input.is_action_pressed("left"):
		input_dir.x += 1
	if Input.is_action_pressed("right"):
		input_dir.x -= 1
	input_dir = input_dir.normalized()
	var move_vec = transform.basis * Vector3(input_dir.x, 0, input_dir.z)
	move_vec.y = 0
	move_vec = move_vec.normalized()

	global_position += move_vec * move_speed * delta



func cue_rotation(delta):
	if Input.is_action_pressed("rleft"):
		rotate_y(turn_speed * delta)
	if Input.is_action_pressed("rright"):
		rotate_y(-turn_speed * delta)
	if Input.is_action_pressed("rup"):
		rotate_object_local(Vector3.RIGHT, turn_speed * delta)
		global_transform.basis = global_transform.basis.orthonormalized()
	if Input.is_action_pressed("rdown"):
		rotate_object_local(Vector3.RIGHT, -turn_speed * delta)
		global_transform.basis = global_transform.basis.orthonormalized()
	rotation.x = clamp(rotation.x, deg_to_rad(-10), deg_to_rad(10))


	
func shot_charge(delta):
	if Input.is_action_just_pressed("shoot"):
		print("charging")
		charging = true
		charge = min_force
		snapping = false
		rest_position = global_position
	if charging and Input.is_action_pressed("shoot"):
		charge += charge_rate * delta
		charge = clamp(charge, min_force, max_force)
		update_pullback_visual()
	if charging and Input.is_action_just_released("shoot"):
		charging = false
		shoot_cue()

		
func shoot_cue():
	shot_lock = true
	var direction = -global_transform.basis.z
	direction.y = 0
	direction = direction.normalized()
	var strength = charge * 4.5
	charge = 0.0
	shot_velocity = direction * strength
	shot_time = 0.0
	shooting = true
	shot_lock = false

func update_pullback_visual():
	var forward_dir = -global_transform.basis.z.normalized()
	var pull_percent = charge / max_force
	pull_offset = pull_percent * max_pullback
	global_position = rest_position + (forward_dir * pull_offset)
