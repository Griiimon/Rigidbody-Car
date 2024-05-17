extends RigidBody3D
class_name Car


@export var acceleration: float= 20.0
@export var brake_friction: float= 1.0
@export var steer_force: float= 10.0
@export var drag: float= 0.1


@onready var front = $Front
@onready var default_friction= physics_material_override.friction
@onready var default_linear_damp= linear_damp



func _physics_process(delta):
	if Input.is_action_pressed("accelerate"):
		# apply acceleration force to the front to stabilize car rotation
		apply_force(get_forward() * acceleration, front.global_position - global_position)
	
	if Input.is_action_pressed("brake"):
		physics_material_override.friction= brake_friction
	else:
		# increase friction when car is sideways in relation to velocity vector
		physics_material_override.friction= lerp(1.0, default_friction, get_forward().dot(linear_velocity.normalized()))
	
	var steering= Input.get_axis("steer_left", "steer_right")
	
	# disable/reduce turning at no/very low speed
	var adjusted_steer_force: float= lerp(0.0, steer_force, clamp(get_speed(), 0.0, 1.0))
	apply_torque(Vector3.DOWN * steering * adjusted_steer_force)

	# dynamically reduce linear damp at high speeds for more sliding
	# and smoother acceleration
	linear_damp= lerp(default_linear_damp, default_linear_damp * 0.1, clamp(get_speed() * drag, 0, 1))

	DebugHud.send("Speed", int(get_speed()))


func get_forward()-> Vector3:
	return -global_basis.z


func get_speed()-> float:
	return linear_velocity.length()
