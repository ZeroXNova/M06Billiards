extends Node3D

@export var move_speed := 3.0
@export var turn_speed := 2.0
@export var fixed_height := 0.5
@export var min_force := 2.0
@export var max_force := 12.0
@export var charge_rate := 8.0
@export var CueBall: RigidBody3D
@export var max_pullback := 0.4
@export var snap_speed := 20.0

var charge := 0.0
var charging := false
var rest_position : Vector3
var pull_offset := 0.0
var snapping := false

func _ready():
	return
	
	

func _process(delta):
	cue_movement(delta)
	cue_rotation(delta)
	lock_height()
	shot_charge(delta)
	if not charging and not snapping:
		rest_position = global_position
	if snapping:
		snap_forward(delta)

func cue_movement(delta):
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
	global_position += (transform.basis * input_dir) * move_speed * delta


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


func lock_height():
	global_position.y = fixed_height
	
func shot_charge(delta):
	if Input.is_action_just_pressed("shoot"):
		print("charging")
		charging = true
		charge = min_force
		snapping = false
		
	if charging and Input.is_action_pressed("shoot"):
		charge += charge_rate * delta
		charge = clamp(charge, min_force, max_force)
		update_pullback_visual()
		
	if Input.is_action_just_released("shoot"):
		print("shoot")
		charging = false
		snapping = true

func shoot_ball():
	if CueBall == null:
		return
	var direction = -global_transform.basis.z.normalized()
	var impulse = direction * charge
	CueBall.apply_impulse(impulse)
	charge = 0.0

func update_pullback_visual():
	var forward_dir = -global_transform.basis.z.normalized()
	var pull_percent = charge / max_force
	pull_offset = pull_percent * max_pullback
	global_position = rest_position + (forward_dir * pull_offset)
	
func snap_forward(delta):
	global_position = global_position.lerp(rest_position, snap_speed * delta)

	if global_position.distance_to(rest_position) < 0.01:
		global_position = rest_position
		snapping = false
		shoot_ball()
