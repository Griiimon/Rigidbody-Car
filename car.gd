extends RigidBody3D
class_name Car


@export var acceleration: float= 20.0
@export var brake_friction: float= 1.0
@export var steer_force: float= 10.0
@export var drag: float= 0.1


@onready var front = $Front
@onready var back = $Back

@onready var default_friction= physics_material_override.friction
@onready var default_linear_damp= linear_damp

var is_on_ground= false



func _physics_process(delta):
	if Input.is_action_pressed("accelerate") and is_on_ground:
		# apply acceleration force to the front to stabilize car rotation
		apply_force(get_forward() * acceleration, front.global_position - global_position)
		#apply_force((get_forward() * acceleration + Vector3.UP * acceleration * 0.01), front.global_position - global_position)
		apply_force(-global_basis.y * acceleration * 0.1, back.global_position - global_position)
	
	
	if Input.is_action_pressed("brake"):
		physics_material_override.friction= brake_friction
	else:
		# increase friction when car is sideways in relation to velocity vector
		physics_material_override.friction= lerp(1.0, default_friction, get_forward().dot(linear_velocity.normalized()))
	
	var steering= Input.get_axis("steer_left", "steer_right")
	if not is_on_ground:
		steering= 0
	
	# disable/reduce turning at no/very low speed
	var adjusted_steer_force: float= lerp(0.0, steer_force, clamp(get_speed() / 10.0, 0.0, 1.0))
	apply_torque(Vector3.DOWN * steering * adjusted_steer_force)

	# dynamically reduce linear damp at high speeds for more sliding
	# and smoother acceleration
	linear_damp= lerp(default_linear_damp, default_linear_damp * 0.1, clamp(get_speed() * drag, 0, 1))

	DebugHud.send("Speed", int(get_speed()))


func _integrate_forces(state):
	is_on_ground= false
	for col_idx in state.get_contact_count():
		if state.get_contact_collider_object(col_idx).collision_layer == 2:
			is_on_ground= true
			break

func get_forward()-> Vector3:
	return -global_basis.z


func get_speed()-> float:
	return linear_velocity.length()
